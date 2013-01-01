module Lagrange
  module Interface
    ##
    # Mechanisms related to synchronizing bookmarks to/from the Safari web
    # browser.
    #
    module Safari
      ##
      # Default location of the user's bookmarks, on OSX.
      #
      # _TODO: Make this platform agnostic..._
      #
      DEFAULT_BOOKMARKS_PATH_RAW="~/Library/Safari/Bookmarks.plist".freeze

      ##
      # The value of `DEFAULT_BOOKMARKS_PATH_RAW` as an absolute path.
      #
      DEFAULT_BOOKMARKS_PATH=File.expand_path(DEFAULT_BOOKMARKS_PATH_RAW).freeze

      ##
      # The default name for the data file(s) in the repository that will hold
      # data representing the last-seen-state of a Safari bookmark set, and
      # the same data in the 'native' format.
      #
      DEFAULT_DATASET="safari".freeze

      ##
      # The name for the directory in the repository in which all
      # Safari-related data is held.
      #
      INTERFACE_NAME="safari".freeze

      ##
      # Ensure that any code needed by this subsystem is loaded once and only
      # once.
      #
      def self.init_dependencies!
        return if(defined?(@initialized) && @initialized)
        @initialized = true
        require 'plist'
      end
    end
  end
end
