##
# We monkey-patch `String` to provide word-wrapping functionality.
#
class String
  ##
  # Will word-wrap this string, producing a new one, to the specified width.
  #
  # Used for CLI help output.
  #
  def word_wrap(max_width)
    return self if(self.length < max_width) # Nothing to wrap.

    left_side = self[0,max_width]
    right_side = self[max_width..-1] || ""
    if(left_side =~ /[ \t]/)
      if(right_side =~ /^[ \t]+/)
        right_side = right_side.lstrip.word_wrap(max_width)
      else
        left_side =~ /^(.*)[ \t]+([^ \t]*)?$/
        left_side = $1.rstrip
        remainder = $2
        right_side = "#{remainder}#{right_side}".lstrip.word_wrap(max_width).lstrip
      end
    else
      right_side = right_side.lstrip.word_wrap(max_width).lstrip
    end

    right_side = "\n#{right_side}" if(right_side != "")
    return left_side + right_side
  end
end

##
# We monkey-patch Object to provide a convenient way to ensure when we get 1 or
# N items, that we have an array.
#
# Essentially, these monkey-patches allow us to DRY up this pattern of code:
#
# ```ruby
# foo = [foo] unless(foo.is_a?(Array))
# ```
#
class Object
  ##
  # Simple returns `[self]`.
  #
  def ensure_array
    return [self]
  end
end

##
# We monkey-patch Array to provide a convenient way to ensure when we get 1 or
# N items, that we have an array.
#
# Essentially, these monkey-patches allow us to DRY up this pattern of code:
#
# ```ruby
# foo = [foo] unless(foo.is_a?(Array))
# ```
#
class Array
  ##
  # Simple returns `self`.
  #
  def ensure_array
    return self
  end
end
