
class TagParser
  class Result < Struct.new(:tags, :errors)
  end

  def self.parse(input)
    result = Result[input.split(" "),[]]

    # YOUR CODE SHOULD GO HERE!
    #
    result
  end
end