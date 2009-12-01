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
      delimeter = (input =~ /,/) ? "," : " "
      parser = StatefulTagParser.new(delimeter)
      # Returning two variables seems dirty, but the 
      # only better alternative I can see is to write 
      # an Either type, which is not really justified.
      tags,errors = parser.parse(input)
      if !errors.empty?
        Result.with_errors errors
      else
        Result.with_tags tags.uniq_by(&:downcase)
      end
    end
  end
  
  def self.check_input input
    if input =~ /([^\w'"\.\-, ])/
      ["The character '#{$1}' is not allowed in tag names"]
    elsif input =~ /(['"]).*,.*\1/
      ["The character ',' is not allowed in tag names.  (No commas inside quotes.)"]
    else
      []
    end
  end
end

class StatefulTagParser
  def initialize delimeter
    @delimeter = delimeter
  end

  def parse input
    @tags, @errors, str = [], [], input
    while @errors.empty? && !str.empty?
      str = consume(str)
    end
    [@tags, @errors]
  end

  #consume!
  def consume str
    if str =~ /^['"]/
      matches = str.match(/^(['"])(.+?)\1(.*)$/)
      if matches
        @tags << matches[2]
        matches[3]
      else
        @errors << "Missing end quote"
        str
      end
    else
      splits = str.split(@delimeter, 2)
      @tags << splits.first
      (splits[1] or "").strip
    end
  end
end
