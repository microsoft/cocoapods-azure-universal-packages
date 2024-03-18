# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-azure-universal-packages/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-azure-universal-packages'
  spec.version       = CocoapodsAzureUniversalPackages::VERSION
  spec.authors       = ['Microsoft Corporation']
  spec.summary       = %q{A CocoaPods plugin for downloading Universal Packages from Azure Artifacts feeds.}
  spec.homepage      = 'https://github.com/microsoft/cocoapods-azure-universal-packages'
  spec.license       = 'MIT'

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'cocoapods', '~> 1.0'
  spec.add_runtime_dependency 'cocoapods-downloader', '~> 2.0'
  spec.add_runtime_dependency 'addressable', '~> 2.6'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'mocha', '~> 1.11'
end
