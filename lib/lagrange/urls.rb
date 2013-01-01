require 'addressable/uri'
require 'cgi'
require 'digest/sha1'

module Lagrange
  module URLs
    def self.uuid(uri)
      uri = uri.to_s if(uri.is_a?(Addressable::URI))
      return Digest::SHA1.hexdigest "#{uri.length}\n#{uri}"
    end

    def self.parse(uri)
      return uri if(uri.is_a?(Addressable::URI))
      load_config("urls")
      # We prefer Addressable here because it doesn't kvetch about things like
      # "|" in query strings.
      return Addressable::URI.parse(uri)
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

      # Not using Addressable's query_values because it doesn't handle
      # duplicated param keys.
      unless(uri.query.nil?)
        if(uri.query =~ /=/)

          tmp = uri.query.split(/;/).map do |subquery|
            params = CGI.parse(subquery)
            params.keys.sort.map do |key|
              next if(global_parameter_blacklist.include?(key))
              next if(per_domain_parameter_blacklist.include?(uri.host) && per_domain_parameter_blacklist[uri.host].include?(key))
              key_escaped = CGI.escape(key)
              values = params[key]
              values = [values] unless(values.is_a?(Array))
              if(values.count > 0)
                values.
                  map { |val| "#{key_escaped}=#{CGI.escape(val)}"}
              else
                "#{key_escaped}"
              end
            end.flatten.reject { |element| element.nil? || element == "" }.join('&')
          end.join(";")
          tmp = nil if(tmp == "")
          uri.query = tmp
        else
          # Not mucking with a query string that has no apparent keys!
        end
      end

      return uri
    end

    def self.add_host_mapping(from, to)
      $stderr.puts("Already have mapping for '#{from}' (to: #{host_mappings[from]}), replacing with: #{to}.") if(!host_mappings[from].nil?)
      host_mappings[from] = to
    end

    def self.blacklist_parameter(name, domain=nil)
      if(domain.nil?)
        global_parameter_blacklist << name
      else
        per_domain_parameter_blacklist[domain] ||= Set.new
        per_domain_parameter_blacklist[domain] << name
      end
    end

    def self.load_config(filename)
      if(!config_files.include?(filename))
        config_files << filename
        filename = Lagrange::config_file(filename)
        if(File.exist?(filename.absolute + ".rb"))
          $stderr.puts("Reading config file: #{filename.absolute}.rb")
          require filename.absolute
        end
      end
    end

    protected

    def self.config_files; @config_files ||= Set.new; end
    def self.host_mappings; @host_mappings ||= {}; end
    def self.global_parameter_blacklist; @global_parameter_blacklist ||= Set.new; end
    def self.per_domain_parameter_blacklist; @per_domain_parameter_blacklist ||= {}; end
  end
end
