namespace :snapshot do
  namespace :push do
    desc "Save information about all presently open Chrome windows/tabs."
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

        window = {
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

        window_data << window
      end

      # TODO: Sort window_data somehow?
      ts = DateTime.now.utc

      sessions_dir = Pathname.
        new('~/Dropbox/Lagrange/Browsers/Sessions').
        expand_path

      FileUtils.mkdir_p(sessions_dir)
      File.open(sessions_dir + ts.strftime("%Y%m%d%H%M%S.json"), "w") do |fh|
        fh.write(JSON.pretty_generate({
          browser:        'chrome',
          hostname:       `hostname -s`.chomp,
          snapshotted_at: ts.strftime("%Y-%m-%d %H:%M:%S %Z"),
          windows:        window_data,
        }))
      end
    end
  end
end
