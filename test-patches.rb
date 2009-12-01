require 'rubygems'
require 'spec'

require 'patches'

describe "Enumerable patches" do
  it "should work on an empty list" do
    [].uniq_by(&:to_s).should == []
  end
  
  it "should work like normal uniq" do
    test_arrays = [[],[1,2,3],[1,2,1,1,1],%w[a b c a D b D d B B]]
    test_arrays.each { |arr|
      arr.uniq_by {|i| i}.should == arr.uniq
    }
  end
  
  it "should uniq on the result of the block" do
    input = [1, 2, 3, "1", "3", "two"]
    expected = [1, 2, 3, "two"]
    input.uniq_by(&:to_s).should == expected
  end

  it "should take the first occurrence" do
    input = %w[a b c a D b d B B]
    expected = %w[a b c D]
    input.uniq_by(&:downcase).should == expected
  end
end
