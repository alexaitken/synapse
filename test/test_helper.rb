if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
  end
end

# Need this for Contender, since we get it from GitHub for now
require 'bundler/setup'

require 'synapse'

require 'pp'
require 'test/unit'
require 'test/unit/rr'

require 'timecop'
require 'shoulda/context'

require 'test_ext'

ActiveSupport::Autoload.eager_autoload!
