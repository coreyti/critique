# -*- encoding: utf-8 -*-
require File.expand_path('../lib/critique/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Corey Innis"]
  gem.email         = ["corey@coolerator.net"]
  gem.description   = %q{critiques your code}
  gem.summary       = %q{critiques your code}
  gem.homepage      = "https://github.com/coreyti/critique"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "critique"
  gem.require_paths = ["lib"]
  gem.version       = Critique::VERSION

  gem.required_ruby_version = ">= 1.9"
  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rr"
  gem.add_development_dependency "simplecov"
end
