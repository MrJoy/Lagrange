module Lagrange
  module Version
    VERSION="0.0.2"
    COPYRIGHT="(C)Copyright 2011-2012, Jon Frisby."

    def self.version
      return VERSION
    end

    def self.show_version_info
      STDERR.puts("Lagrange version #{VERSION}")
      STDERR.puts(COPYRIGHT)
    end
  end
end
