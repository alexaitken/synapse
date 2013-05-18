$:.push File.expand_path '../lib', __FILE__

require 'synapse/version'

Gem::Specification.new do |s|
  s.name = 'synapse-core'
  s.version = Synapse::VERSION.dup
  s.author = 'Ian Unruh'
  s.email = 'ianunruh@gmail.com'
  s.license = 'Apache 2.0'
  s.homepage = 'https://github.com/iunruh/synapse'
  s.description = 'A versatile CQRS and event sourcing framework'
  s.summary = 'A versatile CQRS and event sourcing framework'

  s.files = Dir.glob '{lib,test}/**/*'
  s.require_path = 'lib'

  s.add_dependency 'activesupport'
  s.add_dependency 'atomic'
  s.add_dependency 'logging'
  s.add_dependency 'thread'
end
