class TagParser
  class Result < Struct.new(:tags, :errors)
  end

  def self.parse(input)
    result = Result[[],[]]
    str = input
    while !str.empty?
      str = consume(result, str)
    end
    result
  end
  
  #consume!
  def self.consume result, str
    %w[" '].each { |b|
      if str =~ /^#{b}/
        matches = str.match(/^#{b}([^#{b}]+)#{b}(.*)$/)
        result.tags << matches.to_a[1]
        return matches.to_a[2]
      end
    }
    splits = str.split(" ")
    result.tags << splits.first
    return splits[1..-1].join(" ").strip
  end
end
