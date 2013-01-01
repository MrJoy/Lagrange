module Lagrange
  module FileTypes
    module JSON
      def self.read(fname)
        return self.parse(File.read(fname))
      end

      def self.parse(contents)
        return MultiJson.load(contents, symbolize_keys: true)
      end

      def self.synthesize(contents)
        return MultiJson.dump(contents, pretty: true) + "\n"
      end
    end
  end
end
