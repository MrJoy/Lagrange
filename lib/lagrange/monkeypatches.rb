class String
  def word_wrap(max_width = LAGRANGE_ASSUMED_TERM_WIDTH)
    return self if(self.length < max_width) # Nothing to wrap.

    left_side = self[0,max_width]
    right_side = self[max_width..-1] || ""
    if(left_side =~ /[\s\t]/)
      if(right_side =~ /^[\s\t]+/)
        right_side = right_side.lstrip.word_wrap(max_width)
      else
        left_side =~ /^(.*)[\s\t]+([^\s\t]*)?$/
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

class Object
  def ensure_array
    return [self]
  end
end

class Array
  def ensure_array
    return self
  end
end
