require 'mirrored'

# TODO: Identify the PROPER fix for this, instead of monkey-patching mirrored to NOT DO SSL VALIDATION. >.<
module Mirrored
  class Connection
    def request(resource, method = "get", args = nil)
      url = URI.join(@base_url, resource)
      url.query = args.map { |k,v| "%s=%s" % [URI.encode(k.to_s), URI.encode(v.to_s)] }.join("&") if args

      case method
      when "get"
        req = Net::HTTP::Get.new(url.request_uri)
      when "post"
        req = Net::HTTP::Post.new(url.request_uri)
      end

      req.basic_auth(@username, @password) if @username && @password

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.port == 443)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      res = http.start() { |conn| conn.request(req) }
      res.body
    end
  end
end
# ENV['SSL_CERT_FILE']="/opt/local/etc/certs/cacert.pem"

Mirrored.API_URL[:pinboard] = "https://api.pinboard.in/v1"
module Lagrange
  module Mirrord
    MODULE_NAME="mirrord"
  end
end
