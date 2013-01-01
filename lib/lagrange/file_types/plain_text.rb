module Lagrange
  module FileTypes
    module PlainText
      ##
      # Returns a hash containing `:url`, `:created_at`, and `:updated_at`
      # corresponding to the URL, ctime, and mtime respectively.
      #
      def self.read(fname)
        stat_data = File.stat(fname)

        self.parse(File.read(fname)).map do |url|
          {
            url: url,
            created_at: stat_data.ctime.to_datetime.utc,
            updated_at: stat_data.mtime.to_datetime.utc
          }
        end
      end

      ##
      # Parse the contents of a text file containing one URL per line, ignoring
      # blank lines, or lines that don't look like URLs.
      #
      # Returns an array of raw URLs as strings.
      #
      def self.parse(contents)
        contents = contents.split(/\n/)
        raw_count = contents.count
        contents = contents.
          map { |line| line.chomp.strip }.
          reject do |line|
            uri = (Lagrange::DataTypes::URLs.parse(line) rescue nil)
            uri.blank? || uri.scheme.blank?
          end
        if(contents.count != raw_count)
          Lagrange.logger.warn("Had #{raw_count} lines, but only #{contents.count} look like valid URLs!")
        end
        return contents
      end
    end
  end
end
