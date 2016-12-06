$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "swell_social/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "swell_social"
  s.version     = SwellSocial::VERSION
  s.authors     = ["Gk Parish-Philp", "Michael Ferguson"]
  s.email       = ["gk@playswell.com"]
  s.homepage    = "http://playswell.com"
  s.summary     = "A simple CMS for Rails."
  s.description = "A simple CMS for Rails."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'swell_media'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'

end
