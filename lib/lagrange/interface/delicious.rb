module Lagrange
  module Interface
    module Delicious
      ##
      # The default name for the data file(s) in the repository that will hold
      # data representing the last-seen-state of a Delicious bookmark set.
      #
      DEFAULT_DATASET="delicious".freeze

      ##
      # The name for the directory in the repository in which all
      # Delicious-related data is held.
      #
      INTERFACE_NAME="delicious".freeze

      ##
      # Ensure that any code needed by this subsystem is loaded once and only
      # once.
      #
      def self.init_dependencies!
        return if(defined?(@initialized) && @initialized)
        @initialized = true
        # ENV['SSL_CERT_FILE']="/opt/local/etc/certs/cacert.pem"
        require 'mirrored'
        require_relative './delicious/monkey_patches'

        Mirrored::API_URL[:delicious] = "https://api.del.icio.us/v1/"
      end
    end
  end
end
