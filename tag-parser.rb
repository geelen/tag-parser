require 'patches'

class TagParser
  class Result < Struct.new(:tags, :errors)
    def self.errors errors
      Result[[],errors]
    end
  end

  def self.parse(input)
    input_errors = check_input input
    if !input_errors.empty?
      Result.errors input_errors
    else
      result = Result[[],[]]
      str = input
      while !str.empty?
        str = consume(result, str)
      end
      result.tags.clear if !result.errors.empty?
      result.tags = result.tags.uniq_by(&:downcase)
      result
    end
  end
  
  def self.check_input input
    if input =~ /([^\w'"\.\- ])/
      ["The character '#{$1}' is not allowed in tag names"]
    else
      []
    end
  end
  
  #consume!
  def self.consume result, str
    %w[" '].each { |b|
      if str =~ /^#{b}/
        matches = str.match(/^#{b}([^#{b}]+)#{b}(.*)$/)
        if matches
          result.tags << matches.to_a[1]
          return matches.to_a[2]
        else
          result.errors << "Missing end quote"
          return ""
        end
      end
    }
    splits = str.split(" ")
    result.tags << splits.first
    return splits[1..-1].join(" ").strip
  end
end
