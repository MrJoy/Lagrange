module Lagrange
  module FileTypes
    module Webloc
      def self.read(fname)
        if(File.size(fname) == 0)
          url = raw_resource_fork = `DeRez -e -only 'url ' #{fname.shellescape} | fgrep '$"'`.
            split(/\n/).
            map { |line| line.gsub(/^[ \t]+\$"(.*?)".*$/, '\1').gsub(/([0-9A-F]{2})/, '\1 ').split(/\s+/) }.
            flatten.
            map { |hexcode| hexcode.to_i(16).chr }.
            join('').
            chomp
          if(url.blank?)
            raise "Couldn't retrieve URL from webloc/ftploc's resource fork via DeRez.  Do you have the developer tools installed?"
          end
          return url
        else
          raw_data = `plutil -convert xml1 -o - -s #{fname.shellescape}`
          return self.parse(raw_data)
        end
      end

      def self.parse(contents)
        plist_data = Plist::parse_xml(contents)
        raise "Couldn't parse .webloc/.ftploc file!" if(plist_data.nil?)
        unknown_keys = plist_data.keys - ["URL"]
        if(unknown_keys.count > 0)
          Lagrange.logger.warn("Got unknown keys in webloc: #{unknown_keys.join(', ')}")
        end
        raise "Couldn't find a URL in .webloc/.ftploc file!" if(plist_data["URL"].blank?)
        return plist_data["URL"]
      end

      def self.synthesize(contents)
        raise "Not implemented!"
      end
    end
  end
end
