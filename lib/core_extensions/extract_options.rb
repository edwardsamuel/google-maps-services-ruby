# Ruby Hash.
# @see http://ruby-doc.org/core-2.3.1/Hash.html
class Hash
  # By default, only instances of Hash itself are extractable.
  # Subclasses of Hash may implement this method and return
  # true to declare themselves as extractable. If a Hash
  # is extractable, {Array#extract_options!} pops it from
  # the Array when it is the last element of the Array.
  #
  # @return [boolean] Return `true` if the object is an instance of `Hash`.
  def extractable_options?
    instance_of?(Hash)
  end
end

# Ruby Array.
# @see http://ruby-doc.org/core-2.3.1/Array.html
class Array
  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  # @example
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)        # => {}
  #   options(1, 2, a: :b) # => {:a=>:b}
  #
  # @return [Hash] Options object from array.
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end
end
