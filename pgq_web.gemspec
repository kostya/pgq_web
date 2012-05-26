$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pgq_web/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pgq_web"
  s.version     = PgqWeb::VERSION
  s.authors     = ["Makarchev Konstantin"]
  s.email       = ["kostya27@gmail.com"]
  s.homepage    = "http://github.com/kostya/pgq_web"
  s.summary     = "Web interface for pgq gem. Inspect pgq and londiste queues"
  s.description = "Web interface for pgq gem. Inspect pgq and londiste queues"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "jquery-rails"
  s.add_dependency "pgq", ">= 0.1.2"
  s.add_dependency 'haml-rails'
  s.add_dependency "will_paginate"

  s.add_development_dependency "pg"
end