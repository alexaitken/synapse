source 'https://rubygems.org'

group :test do
  gem 'coveralls'
  gem 'rr'
  gem 'simplecov'
  gem 'timecop'
end

group :test, :development do
  # Used for command validation and serialization
  gem 'activemodel'

  # Used for serialization component
  gem 'oj', platform: :ruby
  gem 'ox', platform: :ruby
end

group :development do
  # Used to generate documentation
  gem 'redcarpet', platform: :ruby
  gem 'yard'
end

# Used for the Mongo event store and saga repository
group :mongo do
  gem 'mongo'
  gem 'bson_ext', platform: :ruby
end

gemspec
