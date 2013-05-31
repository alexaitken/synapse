require 'test_helper'

module Synapse
  module ProcessManager
    class CorrelationTest < Test::Unit::TestCase
      should 'coerce key and value to correct types' do
        correlation = Correlation.new :foo, 'bar'

        assert_equal :foo, correlation.key
        assert_equal 'bar', correlation.value
      end

      should 'be able to determine equality with similar correlations' do
        correlation_a = Correlation.new :foo, 'bar'
        correlation_b = Correlation.new :foo, 'bar'
        correlation_c = Correlation.new :foo, 'baz'

        assert_equal correlation_a, correlation_b
        assert_equal correlation_b, correlation_b
        refute_equal correlation_a, correlation_c
      end
    end
  end
end
