source 'https://rubygems.org'

group :test do
  # Code coverage utilities
  gem 'coveralls'
  gem 'simplecov'

  gem 'test-unit'
  # Temporary fix for lack of MiniTest
  gem 'shoulda-context', :github => 'thoughtbot/shoulda-context', :branch => :master

  # Test doubles
  gem 'rr'
  gem 'test-unit-rr'
  gem 'timecop'

  # Used for Railtie integration testing
  gem 'railties', '~> 3.2'
  gem 'actionpack', '~> 3.2'
end

group :development do
  # Used for command validation and serialization
  gem 'activemodel'

  # Used for deferred activities
  gem 'eventmachine'

  # Used for serialization component
  gem 'oj', platform: :ruby
  gem 'ox', platform: :ruby

  # Used for documentation
  gem 'yard'
  gem 'redcarpet', platform: :ruby
end

gemspec
