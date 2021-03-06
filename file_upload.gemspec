$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "file_upload/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "file_upload"
  s.version     = FileUpload::VERSION
  s.authors     = ["Jeff Ching"]
  s.email       = ["ching.jeff@gmail.com"]
  s.homepage    = "http://chingr.com"
  s.summary     = "Handles uploading files and saving to S3"
  s.description = "Handles uploading files and saving to S3"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "ruby-filemagic"
  s.add_dependency "rails", ">= 3.2.0"
  s.add_dependency "redis"

  s.add_development_dependency "mysql2"
  s.add_development_dependency "jquery-rails"
  s.add_development_dependency "capybara-webkit"
  s.add_development_dependency "connection_pool"
end
