module Lagrange
  module Modules
    module MiscURL
      DEFAULT_DATASET="misc_urls".freeze
      MODULE_NAME="misc_urls"

      def self.init_dependencies!
        return if(defined?(@initialized) && @initialized)
        @initialized = true
        require 'plist'
      end
    end
  end
end
