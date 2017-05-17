# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/forkcms/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-forkcms"
  spec.version       = Capistrano::Forkcms::VERSION
  spec.authors       = ["Tijs Verkoyen"]
  spec.email         = ["capistrano-forcms@verkoyen.eu"]

  spec.summary       = %q{Fork CMS specific Capistrano tasks}
  spec.description   = %q{Capistrano ForkCMS - Easy deployment of ForkCMS 5+ apps with Ruby over SSH}
  spec.homepage      = "https://github.com/tijsverkoyen/capistrano-forkcms"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "capistrano", "~> 3.1"
  spec.add_dependency "capistrano-composer", "~> 0.0.6"
  spec.add_dependency "capistrano-cachetool", "~> 0.1.0"
end
