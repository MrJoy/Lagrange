module Lagrange
  module Models
    class AutoVivifyingOpenStruct
      def initialize(hash = {})
        @table = {}
        merge!(hash)
      end

      def method_missing(*args)
        if(args.length != 1)
          if(args[0] =~ /=$/ && args[1].is_a?(Hash))
            tmp = @table[args[0].to_s.sub(/=$/, '').to_sym] = from_hash(args[1])
          elsif(args[0] =~ /=$/)
            tmp = @table[args[0].to_sym] = args[1]
          # NOTE: The following else condition appears to be impossible despite
          # NOTE: my best efforts at inducing it with all sorts of chicanery,
          # NOTE: including "foo.send(:'bar=')" and such.
          # else
          #   raise "Got a setter method with no parameter: #{args[0]}"
          end
        else
          tmp = @table[args[0].to_sym] ||= AutoVivifyingOpenStruct.new
        end

        return tmp
      end

      def merge!(hash)
        hash.each do |key, value|
          key = key.to_sym
          value_is_hashlike = value.is_a?(Hash) ||
                              value.is_a?(AutoVivifyingOpenStruct)
          if(@table[key].is_a?(AutoVivifyingOpenStruct) && value_is_hashlike)
            @table[key].merge!(value)
          else
            if(value_is_hashlike)
              @table[key] = from_hash(value)
            else
              @table[key] = value
            end
          end
        end
      end

      def as_json(*args)
        return Hash[@table.map do |key, value|
          [key, value.respond_to?(:as_json) ? value.as_json(*args) : value]
        end]
      end

      def to_hash
        return @table
      end

      protected

      def from_hash_shallow(hash)
        return hash if(hash.is_a?(AutoVivifyingOpenStruct))
        return Hash[hash.map do |key, value|
          [key.to_sym, value.is_a?(Hash) ? from_hash(value) : value]
        end]
      end

      def from_hash(hash)
        return hash if(hash.is_a?(AutoVivifyingOpenStruct))
        return AutoVivifyingOpenStruct.new(from_hash_shallow(hash))
      end
    end
  end
end
