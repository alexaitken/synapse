require 'spec_helper'
require 'process_manager/fixtures'

module Synapse
  module ProcessManager

    describe Process do
      it 'initializes with sensible defaults' do
        process = StubProcess.new
        correlation = Correlation.new :process_id, process.id

        # If no identifier was given, one should be generated
        process.id.should be_a(String)
        process.correlations.should include(correlation)
        expect(process.active?).to be_true
      end

      it 'supports deletion of a correlation' do
        process = StubProcess.new

        key = :order_id
        value = '512d5467'

        process.cause_correlate key, value
        process.correlations.should include(Correlation.new(key, value))

        process.cause_dissociate key, value
        process.correlations.should_not include(Correlation.new(key, value))
      end

      it 'can be marked as finished' do
        process = StubProcess.new
        process.cause_finish

        expect(process.active?).to be_false
      end
    end

  end
end
