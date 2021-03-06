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
      delimiter = (input =~ /,/) ? "," : " "
      parser = StatefulTagParser.new(delimiter)
      tags,errors = parser.parse(input)
      if !errors.empty?
        Result.with_errors errors
      else
        Result.with_tags tags.uniq_by(&:downcase)
      end
    end
  end
  
  private
  
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
  def initialize delimiter
    @delimiter = delimiter
  end

  def parse input
    @tags, @errors, str = [], [], input
    while @errors.empty? && !str.empty?
      # consumes a token from the front of string into @tags or @errors, returning the rest
      str = consume(str)
    end  
    # Returning two variables seems dirty, since in practice it's always
    # one or the other. The Either typeclass would fit perfectly here,
    # but is more complex than justified by this use case.
    [@tags, @errors]
  end

  private

  #consume!
  def consume str
    if str =~ /^['"]/
      quoted_token str
    else
      simple_token str
    end
  end

  def quoted_token str
    #extracts first quote, quoted section, and remaining string
    matches = str.match(/^(['"])(.+?)\1#{@delimiter}(.*)$/)
    if matches
      @tags << matches[2]
      matches[3].strip
    else
      @errors << "Missing end quote"
      str
    end
  end

  def simple_token str
    splits = str.split(@delimiter, 2)
    @tags << splits.first
    (splits[1] or "").strip
  end
end
