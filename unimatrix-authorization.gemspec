# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unimatrix/authorization/version'

Gem::Specification.new do |spec|
  spec.name          = "unimatrix-authorization"
  spec.version       = Unimatrix::Authorization::VERSION
  spec.authors       = ["David Bragdon"]
  spec.email         = ["davidbragdon@sportsrocket.com"]
  spec.summary       = %q{Unimatrix::Authorization is used to communicate with Keymaker.}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "addressable"
  spec.add_runtime_dependency "fnv", "~> 0.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end