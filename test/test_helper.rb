require 'simplecov'

if ENV['COVERAGE']
  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'pp'
require 'test/unit'
require 'rr'
require 'synapse'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
