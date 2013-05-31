if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'pp'
require 'synapse'
require 'test/unit'
require 'shoulda/context'
require 'rr'
require 'timecop'

require 'test_ext'

# I guess RR broke
# http://stackoverflow.com/questions/3657972
unless defined? Test::Unit::AssertionFailedError
  Test::Unit::AssertionFailedError = ActiveSupport::TestCase::Assertion
end

ActiveSupport::Autoload.eager_autoload!
