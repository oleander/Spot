# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "spot"
  s.version     = "0.1.4"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Linus Oleander"]
  s.email       = ["linus@oleander.nu"]
  s.homepage    = "https://github.com/oleander/Spot"
  s.summary     = %q{A Ruby implementation of the Spotify Meta API}
  s.description = %q{A Ruby implementation of the Spotify Meta API.}

  s.rubyforge_project = "spot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("json_pure")
  s.add_dependency("rest-client")
  s.add_dependency("abstract")
  s.add_dependency("levenshteinish")
  s.add_dependency("charlock_holmes")
  
  s.add_development_dependency("rspec")
  s.add_development_dependency("vcr")
  s.add_development_dependency("webmock", "~> 1.8.0")
end
