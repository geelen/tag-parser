require 'patches'

class TagParser
  class Result < Struct.new(:tags, :errors)
    def self.with_errors errors
      Result[[],errors]
    end
    def self.with_tags tags
      Result[tags,[]]
    end
  end

  def self.parse(input)
    input_errors = check_input input
    if !input_errors.empty?
      Result.with_errors input_errors
    else
      # Returning two variables seems dirty, but the 
      # only better alternative I can see is to write 
      # an Either type, which is not really justified.
      tags,errors = get_tags(input)
      if !errors.empty?
        Result.with_errors errors
      else
        Result.with_tags tags
      end
    end
  end
  
  def self.check_input input
    if input =~ /([^\w'"\.\- ])/
      ["The character '#{$1}' is not allowed in tag names"]
    else
      []
    end
  end
  
  def self.get_tags input
    tags, errors, str = [], [], input
    while errors.empty? && !str.empty?
      str = consume(tags, errors, str)
    end
    [tags, errors]
  end
  
  #consume!
  def self.consume tags, errors, str
     if str =~ /^['"]/
      matches = str.match(/^(['"])([^\1]+?)\1(.*)$/)
      if matches
        tags << matches[2]
        matches[3]
      else
        errors << "Missing end quote"
        str
      end
    else
      splits = str.split(" ",2)
      tags << splits.first
      splits[1] or ""
    end
  end
end
