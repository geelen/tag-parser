class TagParser
  class Result < Struct.new(:tags, :errors)
  end

  def self.parse(input)
    result = Result[[],[]]
    if input =~ /([^\w'"\.\- ])/
      return Result[[],["The character '#{$1}' is not allowed in tag names"]]
    end
    str = input
    while !str.empty?
      str = consume(result, str)
    end
    result.tags.clear if !result.errors.empty?
    result
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
