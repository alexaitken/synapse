require 'coveralls'

Coveralls.wear!

require 'pp'
require 'test/unit'
require 'rr'
require 'synapse'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
