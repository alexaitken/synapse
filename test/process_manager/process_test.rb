require 'test_helper'

module Synapse
  module ProcessManager

    class ProcessTest < Test::Unit::TestCase
      def test_initialize
        process = StubProcess.new
        correlation = Correlation.new :process_id, process.id

        # If no identifier was given, one should be generated
        refute process.id.nil?
        assert process.correlations.include? correlation
        assert process.active?
      end

      def test_dissociate_from
        process = StubProcess.new

        key = :order_id
        value = '512d5467'

        process.cause_correlate key, value
        assert process.correlations.include? Correlation.new(key, value)

        process.cause_dissociate key, value
        refute process.correlations.include? Correlation.new(key, value)
      end

      def test_finish
        process = StubProcess.new
        process.cause_finish

        refute process.active?
      end
    end

    class StubProcess < Process
      def cause_finish
        finish
      end

      def cause_correlate(key, value)
        correlate_with key, value
      end
      def cause_dissociate(key, value)
        dissociate_from key, value
      end
    end

  end
end
