module Lagrange
  class AutoVivifyingOpenStruct < OpenStruct
    def initialize(hash = {})
      super(from_hash_shallow(hash))
    end

    def method_missing(*args)
      if(args.length != 1)
        if(args[0] =~ /=$/ && args[1].is_a?(Hash))
          @table[args[0].to_s.sub(/=$/, '').to_sym] = from_hash(args[1])
        else
          return super(*args)
        end
      else
        @table[args[0].to_sym] ||= AutoVivifyingOpenStruct.new
      end
    end

    def merge(hash)
      from_hash_shallow(hash).each do |key, value|
        @table[key.to_sym] = value
      end
    end

    def as_json(*args)
      return Hash[@table.map do |key, value|
        [key, value.respond_to?(:as_json) ? value.as_json(*args) : value]
      end]
    end

    protected

    def from_hash_shallow(hash)
      return Hash[hash.map do |key, value|
        [key.to_sym, value.is_a?(Hash) ? from_hash(value) : value]
      end]
    end

    def from_hash(hash)
      return AutoVivifyingOpenStruct.new(from_hash_shallow(hash))
    end
  end
end
  # x = AutoVivifyingOpenStruct.new
  # x.safari.whatever.bleah = 3
  # x.as_json
  # x.safari.whatever = { :bleah => { :foo => 3 }, :meh => "whatever" }
  # x.as_json
  # x.safari.whatever.bleah


  # y = AutoVivifyingOpenStruct.new({ :safari => { :whatever => { :bleah => { :foo => 3 }, :meh => "whatever" } } })
  # y.safari.whatever.bleah
