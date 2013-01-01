module Lagrange
  module FileTypes
    module Webloc
      ##
      # Returns a hash containing `:url`, `:title`, `:created_at`,
      # `:updated_at` corresponding to the URL, filename (without extension),
      # ctime, and mtime respectively.
      #
      # Will attempt to read resource-fork based .webloc/.ftploc files but this
      # will only work if you have DeRez installed, which comes with Xcode.
      #
      def self.read(fname)
        stat_data = File.stat(fname)
        result = {
          title: File.basename(fname.sub(/\.(webloc|ftploc)$/, '')),
          created_at: stat_data.ctime.to_datetime.utc,
          updated_at: stat_data.mtime.to_datetime.utc
        }

        if(File.size(fname) == 0)
          url = `DeRez -e -only 'url ' #{fname.shellescape} | fgrep '$"'`.
            split(/\n/).
            map { |line| line.gsub(/^[ \t]+\$"(.*?)".*$/, '\1').gsub(/([0-9A-F]{2})/, '\1 ').split(/\s+/) }.
            flatten.
            map { |hexcode| hexcode.to_i(16).chr }.
            join('').
            chomp.
            strip
          if(url.blank?)
            raise "Couldn't retrieve URL from webloc/ftploc's resource fork via DeRez.  Do you have the developer tools installed?"
          end
          result[:url] = url
        else
          raw_data = `plutil -convert xml1 -o - -s #{fname.shellescape}`
          result[:url] = self.parse(raw_data)
        end

        return result
      end

      ##
      # Parse the contents of a plist-based based .webloc/.ftploc, provided
      # that the contents are in XML form.
      #
      # Returns the URL value as a string.
      #
      def self.parse(contents)
        plist_data = Plist::parse_xml(contents)
        raise "Couldn't parse .webloc/.ftploc file!" if(plist_data.nil?)
        unknown_keys = plist_data.keys - ["URL"]
        if(unknown_keys.count > 0)
          Lagrange.logger.warn("Got unknown keys in webloc: #{unknown_keys.join(', ')}")
        end
        raise "Couldn't find a URL in .webloc/.ftploc file!" if(plist_data["URL"].blank?)
        return plist_data["URL"].strip
      end
    end
  end
end
