module Lagrange
  module Interface
    module Safari
      DEFAULT_BOOKMARKS_PATH_RAW="~/Library/Safari/Bookmarks.plist".freeze
      DEFAULT_BOOKMARKS_PATH=File.expand_path(DEFAULT_BOOKMARKS_PATH_RAW).freeze
      DEFAULT_DATASET="safari".freeze
      INTERFACE_NAME="safari"

      def self.init_dependencies!
        return if(defined?(@initialized) && @initialized)
        @initialized = true
        require 'plist'
      end
    end
  end
end
