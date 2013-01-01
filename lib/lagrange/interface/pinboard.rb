module Lagrange
  module Interface
    module Pinboard
      ##
      # The default name for the data file(s) in the repository that will hold
      # data representing the last-seen-state of a Pinboard bookmark set.
      #
      DEFAULT_DATASET="pinboard".freeze

      ##
      # The name for the directory in the repository in which all
      # Pinboard-related data is held.
      #
      INTERFACE_NAME="pinboard".freeze
      def self.init_dependencies!
        return if(defined?(@initialized) && @initialized)
        @initialized = true
        require 'pinboard'
      end
    end
  end
end
