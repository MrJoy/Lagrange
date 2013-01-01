module Lagrange
  module Version
    VERSION="0.0.2"
    COPYRIGHT="(C)Copyright 2011-2012, Jon Frisby."

    def self.version
      return VERSION
    end

    def self.extended_version_info
      return [
        "Lagrange v.#{VERSION}",
        COPYRIGHT,
      ]
    end
  end
end
