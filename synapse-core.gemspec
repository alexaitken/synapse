require File.expand_path '../lib/synapse/version', __FILE__

Gem::Specification.new do |s|
  s.name = 'synapse-core'
  s.version = Synapse::VERSION.dup
  s.author = 'Ian Unruh'
  s.email = 'ianunruh@gmail.com'
  s.license = 'Apache 2.0'
  s.homepage = 'https://github.com/ianunruh/synapse'
  s.description = 'A versatile CQRS and event sourcing framework'
  s.summary = 'A versatile CQRS and event sourcing framework'

  s.files = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.test_files = Dir['spec/**/*']
  s.require_path = 'lib'

  s.add_dependency 'abstract_type', '~> 0.0.6'
  s.add_dependency 'adamantium', '~> 0.0.11'
  s.add_dependency 'equalizer', '~> 0.0.5'
  s.add_dependency 'contender', '~> 0.2.0'
  s.add_dependency 'ref', '~> 1.0.5'
  s.add_dependency 'thread_safe', '~> 0.1.2'

  # Development dependencies
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard-rspec'

  # Testing dependencies
  s.add_development_dependency 'rr'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
end
