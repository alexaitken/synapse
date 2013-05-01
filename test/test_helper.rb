if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

require 'pp'
require 'test/unit'
require 'rr'
require 'synapse'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
