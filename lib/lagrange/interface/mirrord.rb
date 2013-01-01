module Lagrange
  module Interface
    module Mirrord
      INTERFACE_NAME="mirrord"
      def self.init_dependencies!
        return if(defined?(@initialized) && @initialized)
        @initialized = true
        # ENV['SSL_CERT_FILE']="/opt/local/etc/certs/cacert.pem"
        require 'mirrored'
        require_relative './mirrord/monkey_patches'

        Mirrored::API_URL[:delicious] = "https://api.del.icio.us/v1/"
        Mirrored::API_URL[:pinboard] = "https://api.pinboard.in/v1"
      end
    end
  end
end
