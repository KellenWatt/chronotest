require "date"
Gem::Specification.new do |s|
  # Required
  s.name = "chronotest"
  s.version = "0.0.1"
  s.summary = "Asynchronously-run testing framework"
  s.author = "Kellen Watt"
  s.files = Dir["lib/**/*"]
  
  # Recommended
  s.license = "MIT"
  s.description = "A framework for safely running tests asynchronously, including safe, per-test logging."
  s.date = Date.today.strftime("%Y-%m-%d")
  s.email = ""
  s.homepage = ""
  s.metadata = {}

  s.required_ruby_version = ">= 2.3.0"
  
  # Optional and situational - delete or keep, as necessary
  # s.bindir = "bin"
  # s.executables = []
  # s.required_ruby_version = ">= 2.5" # Sensible default
end
