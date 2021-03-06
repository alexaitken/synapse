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
  s.test_files = Dir['test/**/*']
  s.require_path = 'lib'

  s.add_dependency 'activesupport', '~> 4.0.2'
  s.add_dependency 'atomic', '~> 1.1'
  s.add_dependency 'logging', '~> 1.8'
  s.add_dependency 'contender', '~> 0.1.0'
  s.add_dependency 'ref', '~> 1.0'
end
