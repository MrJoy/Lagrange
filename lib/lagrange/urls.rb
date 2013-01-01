require 'uri'

module Lagrange
  module URLs
    def self.parse(uri)
      return uri if(uri.is_a?(URI))

      # First, compensate for some nitpickiness on the part of the URI class...
      uri.gsub(/\|/, '%7C')
      return URI.parse(uri)
    end

    def self.canonicalize(uri)
      uri = parse(uri)
      return uri.normalize
    end

    def self.is_valid?(uri)
      uri = parse(uri) rescue nil
      return uri.nil? || uri.scheme.nil?
    end

    def self.cleanup(uri)
      uri = canonicalize(parse(uri))
      uri.host = host_mappings[uri.host] || uri.host
      query = uri.query
      return uri
    end

    def self.add_host_mapping(from, to)
      $stderr.puts("Already have mapping for '#{from}' (to: #{host_mappings[from]}), replacing with: #{to}.") if(!host_mappings[from].nil?)
      host_mappings[from] = to
    end

    protected

    def self.host_mappings
      @host_mappings ||= {}
    end
  end
end
