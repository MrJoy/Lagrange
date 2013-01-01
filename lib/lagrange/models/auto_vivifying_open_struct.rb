module Lagrange
  module Models
    ##
    # This class behaves similarly to `OpenStruct` but will auto-vivify
    # arbitrarily deep call chains, and gracefully handle assignment and
    # merging of normal hashes as well.
    #
    class AutoVivifyingOpenStruct
      ##
      # Given a `Hash`, or another `AutoVivifyingOpenStruct`, will pre-populate
      # the new instance accordingly.
      #
      def initialize(hash = {})
        @table = {}
        merge!(hash)
      end

      ##
      # Herein lies the magic/dragons.  Unlike `OpenStruct`, we don't create
      # getter/setter methods on-demand, in order to simplify some funky corner
      # cases around handling `Hash` assignments.
      #
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

      ##
      # Takes a `Hash` or a `AutoVivifyingOpenStruct`, and does a deep-merge,
      # destructively updating this instance.  If a node was not a sub-tree in
      # the present instance, but is in the instance being merged, then it will
      # be a sub-tree after the merge.  If a node was a sub-tree in the present
      # instance, but is not in the instance being merged, then it will not be
      # a sub-tree after the merge.
      #
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

      ##
      # Convert this to a light-weight set of nested hashes/etc, as opposed to
      # the behavior expressed by `OpenStruct` which laid bare its internals to
      # the world.
      #
      def as_json(*args)
        return Hash[@table.map do |key, value|
          [key, value.respond_to?(:as_json) ? value.as_json(*args) : value]
        end]
      end

      protected

      ##
      # Takes a `Hash`, and returns a `Hash`, but with all members of the
      # `Hash` having been recursively converted to use
      # `AutoVivifyingOpenStruct` where appropriate.
      #
      # Will early-out if given a `AutoVivifyingOpenStruct`.
      #
      def from_hash_shallow(hash)
        return hash if(hash.is_a?(AutoVivifyingOpenStruct))
        return Hash[hash.map do |key, value|
          [key.to_sym, value.is_a?(Hash) ? from_hash(value) : value]
        end]
      end

      ##
      # Takes a `Hash`, and returns an `AutoVivifyingOpenStruct`, with all
      # members of the `Hash` having been recursively converted to use
      # `AutoVivifyingOpenStruct` where appropriate.
      #
      # Will early-out if given a `AutoVivifyingOpenStruct`.
      #
      def from_hash(hash)
        return hash if(hash.is_a?(AutoVivifyingOpenStruct))
        return AutoVivifyingOpenStruct.new(from_hash_shallow(hash))
      end
    end
  end
end
