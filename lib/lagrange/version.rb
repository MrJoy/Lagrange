module Lagrange
  module Version
    VERSION="0.0.2".freeze
    RELEASE_DATE="2012-06-13".freeze
    COPYRIGHT="(C)Copyright 2011-2012, Jon Frisby.".freeze

    def self.show_version_info
      STDERR.puts("Lagrange version #{VERSION}, #{RELEASE_DATE}")
      STDERR.puts(COPYRIGHT)
    end
  end
end
