require "date"
Gem::Specification.new do |s|
  # Required
  s.name = "chronotest"
  s.version = "0.0.1"
  s.summary = ""
  s.author = "Kellen Watt"
  s.files = Dir["lib/**/*"]
  
  # Recommended
  s.license = ""
  s.description = ""
  s.date = Date.today.strftime("%Y-%m-%d")
  s.email = ""
  s.homepage = ""
  s.metadata = {}
  
  
  # Optional and situational - delete or keep, as necessary
  # s.bindir = "bin"
  # s.executables = []
  # s.required_ruby_version = ">= 2.5" # Sensible default
end
