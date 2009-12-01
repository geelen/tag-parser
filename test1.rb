require 'rubygems'
require 'spec'

# We need code to parse tags that authors will apply to their items.
# The input will be a space (and if you are awesome comma) seperated list of words, with
# quotes used to allow spaces in tag names.
#
# Eg:
#
# green white
# XML 'Web 2.0'
# Grunge New-Age Cyber-Punk
#
# An awesome solution will also allow:
#
# green, off white, "light brown"
#
# : but this is an optional feature.
#
# I suggest that you read through all the specs before you get started.
#
# run this file with:
#   
#   spec test1.rb
#
# If any of the specs are wrong, or don't make sense, then please let me know so we can fix them.

require 'tag-parser'

describe TagParser do
  it "should allow nothing as valid input" do
    result = TagParser.parse("")
    result.tags.should == []
    result.errors.should == []
  end

  it "should seperate tags on spaces" do
    result = TagParser.parse("one two three four")
    result.tags.should == ["one", "two", "three", "four"]
    result.errors.should == []
  end

  it "should allow double quotes to allow spaces in tags" do
    result = TagParser.parse('one "two parts" three four')
    result.tags.should == ["one", "two parts", "three", "four"]
    result.errors.should == []
  end

  it "should crack the sads if quotes are not closed properly" do
    result = TagParser.parse('one "two" parts "three four')
    result.tags.should == []
    result.errors.should == ["Missing end quote"]
  end

  it "should allow numbers and full-stops" do
    result = TagParser.parse('one "web 2.0" three 4000')
    result.tags.should == ["one", "web 2.0", "three", "4000"]
    result.errors.should == []
  end

  it "should allow dashes" do
    result = TagParser.parse("one two-point-two three four")
    result.tags.should == ["one", "two-point-two", "three", "four"]
    result.errors.should == []
  end

  it "should not allow other crazy characters" do
    result = TagParser.parse('clinton@gmail.com "web 2.0" three four')
    result.tags.should == []
    result.errors.should == ["The character '@' is not allowed in tag names"]
  end

  it "should allow single quotes to allow spaces in tags" do
    result = TagParser.parse("one 'two parts' three four")
    result.tags.should == ["one", "two parts", "three", "four"]
    result.errors.should == []
  end

  it "should force quotes to be closed with the matching quote" do
    result = TagParser.parse("one 'two parts\" three four")
    result.tags.should == []
    result.errors.should == ["Missing end quote"]

    result = TagParser.parse("one \"two parts' three four")
    result.tags.should == []
    result.errors.should == ["Missing end quote"]
  end

  it "should preserve case" do
    result = TagParser.parse("One 'two parts' tHree four")
    result.tags.should == ["One", "two parts", "tHree", "four"]
    result.errors.should == []
  end

  it "should ignore duplicates, irrespective of case, using the case of the first instance found" do
    result = TagParser.parse("One three 'two parts' tHree four one")
    result.tags.should == ["One", "three", "two parts", "four"]
    result.errors.should == []
  end
end

# If you are REALLY clever, then do this as well
describe TagParser do
  it "should seperate tags on commas also" do
    result = TagParser.parse("one, two three,   four")
    result.tags.should == ["one", "two three", "four"]
    result.errors.should == []
  end
  
  it "should not seperate a quoted tag on a comma, but report an error" do
    result = TagParser.parse('one "two parts, three" four')
    result.tags.should == []
    result.errors.should == ["The character ',' is not allowed in tag names.  (No commas inside quotes.)"]
  end

  it "should seperate all tags by commas, if used once" do
    result = TagParser.parse('one,           two three four ')
    result.tags.should == ['one', 'two three four']
    result.errors.should == []
  end

  it "should not get confused if both commas and double-quotes are combined" do
    result = TagParser.parse('one, "two three", four')
    result.tags.should == ['one', 'two three', 'four']
    result.errors.should == []
  end
end
