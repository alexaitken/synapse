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
require 'test/unit/rr'
require 'timecop'
require 'shoulda/context'

require 'test_ext'

ActiveSupport::Autoload.eager_autoload!
