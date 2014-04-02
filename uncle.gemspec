$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "uncle/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "uncle"
  s.version     = Uncle::VERSION
  s.authors     = ["Stevie Graham"]
  s.email       = ["sjtgraham@mac.com"]
  s.homepage    = "https://github.com/stevegraham/uncle"
  s.summary     = "Ruby on Rails URL helpers for relative resources"
  s.description = "Helpers methods that reflect on your application route " +
                  "set to dynamically infer correct URLs for parent and " +
                  "nested child resources."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "rails", "~> 4.0.4"

  s.add_development_dependency "sqlite3"
end
