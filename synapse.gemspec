Gem::Specification.new do |s|
  s.name = 'synapse'
  s.version = '0.1.2'
  s.author = 'Ian Unruh'
  s.email = 'ianunruh@gmail.com'
  s.homepage = 'https://github.com/iunruh/synapse'
  s.description = 'A versatile CQRS and event sourcing framework'
  s.summary = 'A versatile CQRS and event sourcing framework'

  s.files = Dir.glob '{lib,test}/**/*'
  s.require_path = 'lib'

  s.add_dependency 'activesupport'
  s.add_dependency 'logging'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard'
end
