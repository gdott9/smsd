# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smsd/version'

Gem::Specification.new do |spec|
  spec.name          = "smsd"
  spec.version       = SMSd::VERSION
  spec.authors       = ["Guillaume DOTT"]
  spec.email         = ["guillaume.dott@lafourmi-immo.com"]
  spec.description   = %q{Automatically answers to SMS using Biju to access your 3G key}
  spec.summary       = %q{Automatically answers to SMS}
  spec.homepage      = ""
  spec.license       = "AGPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'biju'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
