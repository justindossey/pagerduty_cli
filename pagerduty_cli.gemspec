# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pagerduty_cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'pagerduty_cli'
  spec.version       = PagerdutyCli::VERSION
  spec.authors       = ['Justin Dossey']
  spec.email         = ['justin.dossey@newcontext.com']
  spec.summary       = 'ruby CLI for PagerDuty API'
  spec.description   = 'ruby CLI for PagerDuty API. '\
    'Supports sending triggers and resolves.'
  spec.homepage      = 'https://github.com/justindossey/pagerduty_cli'
  spec.license       = 'MIT'

  spec.required_ruby_version = ">= 1.9.3"
  spec.bindir        = 'bin'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'pagerduty', '~> 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 12.2'
end
