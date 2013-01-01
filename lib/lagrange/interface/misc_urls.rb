module Lagrange
  module Interface
    module MiscURL
      DEFAULT_DATASET="misc_urls".freeze
      INTERFACE_NAME="misc_urls"

      def self.init_dependencies!
        return if(defined?(@initialized) && @initialized)
        @initialized = true
        require 'plist'
      end
    end
  end
end
