require "chronotest/autorun"

class Before < Chronotest
  
  before("math should work"){ @four = 4 }

  try "math should work" do
    assert 2 + 2 == @four;
  end

  try "true should be true" do
    fail unless true;
  end

  try "@four shouldn't be defined" do
    refute defined? @four
  end

  try "this test will skip" do
    skip
    fail
  end

  try "output is properly compared" do
    prints "Hello\nworld!\n" do
      puts "Hello"
      puts "world!"
    end
  end

  try "detects an error being thrown" do
    raises do
      raise StandardError
    end
  end
end
