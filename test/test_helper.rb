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
require 'test/unit'
require 'rr'
require 'timecop'
require 'synapse'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
