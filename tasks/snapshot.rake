namespace :snapshot do
  namespace :push do
    desc "Save information about all presently/previously open Safari windows/tabs to Dropbox."
    task :safari do
      require 'json'
      require 'pathname'
      require 'osx/plist'
      # TODO: Simple wrapper around Safari data...
      session_fname = Pathname.
        new('~/Library/Safari/LastSession.plist').
        expand_path
      session_data = OSX::PropertyList.load_file(session_fname)
      raise "Unexpected session version: #{session_data['SessionVersion']}" unless session_data['SessionVersion'] == '1.0'
      windows = session_data['SessionWindows']
      unexpected_window_state_versions =
        windows.
        map { |window| window['WindowStateVersion'] }.
        sort.
        uniq - ['2.0']

      raise "Unexpected window state version(s): #{unexpected_window_state_versions.join(', ')}" unless unexpected_window_state_versions.length == 0
      # TODO: Use SelectedTabIndex to get context-free info about selected index...

      window_data = []
      windows.each do |window_info|
        tmp = window_info['WindowContentRect'].
          match(/\A\{\{(-?\d+)\s*,\s*(-?\d+)\}\s*,\s*\{(-?\d+)\s*,\s*(-?\d+)\}\}/).
          to_a
        raise "Unparseable window size: #{window_info['WindowContentRect']}" unless(tmp && tmp.length == 5)

        (position, size) =
          tmp[1..-1].
          map(&:to_i).
          in_groups_of(2).
          map { |pair| Hash[['x', 'y'].zip(pair)] }

        window_data << {
          minimized:  window_info['Miniaturized'],
          position:   position,
          size:       size,
          tabs:       window_info['TabStates'].
                        map do |tab_info|
                          {
                            url:        tab_info['TabURL'].force_encoding('UTF-8'),
                            title:      tab_info['TabTitle'].force_encoding('UTF-8'),
                            tab_id:     tab_info['TabIdentifier'].to_i,
                            tab_uuid:   tab_info['TabUUID'].force_encoding('UTF-8'),
                          }
                        end.
                        sort { |a, b| a[:url] <=> b[:url] }
        }
      end

      # TODO: Sort window_data somehow?
      ts = DateTime.now.utc

      sessions_dir = Pathname.
        new('~/Dropbox/Lagrange/Browsers/Sessions').
        expand_path

      result = JSON.pretty_generate({
        browser:        'safari',
        hostname:       `hostname -s`.chomp,
        snapshotted_at: ts.strftime("%Y-%m-%d %H:%M:%S %Z"),
        windows:        window_data,
      })

      FileUtils.mkdir_p(sessions_dir)
      File.open(sessions_dir + ts.strftime("%Y%m%d%H%M%S.json"), "w") do |fh|
        fh.write(result)
      end
    end

    desc "Save information about all presently open Chrome windows/tabs to Dropbox."
    task :chrome do
      require 'json'
      require 'pathname'
      # TODO: Simple wrapper around chrome-cli...
      raw = `chrome-cli list windows`
      windows = `chrome-cli list windows`.
        split(/^\[(\d+)\]\s*([^\[]*)/).
        in_groups_of(3). # Empty string, ID, and current title.
        map { |(_,id,_)| id }. # ... only care about title.
        map(&:to_i) # ... types are nice.

      # TODO: Include info about selected window, and selected tab per window.
      # TODO: Include info about minimized windows.
      window_data = []
      windows.each do |window_id|
        urls = Hash[
          `chrome-cli list links -w #{window_id}`.
            split(/^\[(\d+)\]\s*([^\[]*)/).
            in_groups_of(3).
            map { |(_,id,url)| [id.to_i, url.chomp] }
        ]
        titles = Hash[
          `chrome-cli list tabs -w #{window_id}`.
            split(/^\[(\d+)\]\s*([^\[]*)/).
            in_groups_of(3).
            map { |(_,id,title)| [id.to_i, title.chomp] }
        ]

        window_data << {
          position: Hash[
                      `chrome-cli position -w #{window_id}`.
                        chomp.
                        split(/\s*,\s*/).
                        map { |coord| coord.split(/\s*:\s*/) }
                    ],
          size:     Hash[
                      `chrome-cli size -w #{window_id}`.
                        chomp.
                        split(/\s*,\s*/).
                        map { |coord| coord.split(/\s*:\s*/) }
                    ],
          tabs:     urls.
                      map do |id, url|
                        {
                          url: url,
                          title: titles[id]
                        }
                      end.
                      sort { |a, b| a[:url] <=> b[:url] }
        }
      end

      # TODO: Sort window_data somehow?
      ts = DateTime.now.utc

      sessions_dir = Pathname.
        new('~/Dropbox/Lagrange/Browsers/Sessions').
        expand_path

      result = JSON.pretty_generate({
        browser:        'chrome',
        hostname:       `hostname -s`.chomp,
        snapshotted_at: ts.strftime("%Y-%m-%d %H:%M:%S %Z"),
        windows:        window_data,
      })

      FileUtils.mkdir_p(sessions_dir)
      File.open(sessions_dir + ts.strftime("%Y%m%d%H%M%S.json"), "w") do |fh|
        fh.write(result)
      end
    end
  end
end
