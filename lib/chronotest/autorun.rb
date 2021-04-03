require "chronotest"
class Chronotest
  def self.autorun
    at_exit {@@classes.each {|c,_| c.run}}
  end
end

Chronotest.autorun
