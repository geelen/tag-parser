# I like to build up a library of useful patches,
# particularly on Enumerable, because I use them
# a lot. But whether this is monkey patched or not 
# is a matter of preference.
#
# See http://github.com/nkpart/prohax for a gem
# a friend of mine extracted from our codebase back
# in Brisbane - it's a similar idea.

module Enumerable
  def uniq_by &key_function
    inject([[],{}]) { |(accum, key_hash), elem|
      key = key_function.call(elem)
      if !key_hash.has_key? key
        key_hash[key] = elem
        accum << elem
      end
      [accum,key_hash]
    }.first
  end
end
