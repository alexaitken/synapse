source 'https://rubygems.org'

gem 'contender', :github => 'ianunruh/contender', :branch => :master

group :test do
  gem 'test-unit-rr'
  gem 'shoulda-context'

  # Code coverage utilities
  gem 'coveralls'
  gem 'simplecov'

  # Test doubles
  gem 'rr'
  gem 'timecop'

  # Used for Railtie integration testing
  gem 'rails', '~> 3.2.13'
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
