source 'https://rubygems.org'

group :test do
  # Code coverage utilities
  gem 'coveralls'
  gem 'simplecov'

  gem 'test-unit'
  gem 'shoulda-context'

  # Test doubles
  gem 'rr'
  gem 'test-unit-rr'
  gem 'timecop'
end

group :development do
  # Used for command validation and serialization
  gem 'activemodel'

  # Used for deferred activities
  gem 'eventmachine'

  # Used for serialization component
  gem 'oj', '~> 2.0.14', platform: :ruby
  gem 'ox', '~> 2.0.4', platform: :ruby

  # Used for documentation
  gem 'yard'
  gem 'redcarpet', platform: :ruby
end

gemspec
