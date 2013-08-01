require 'spec_helper'
require 'saga/fixtures'

module Synapse
  module Saga

    describe Saga do
      it 'initializes with sensible defaults' do
        saga = StubSaga.new
        correlation = Correlation.new :saga_id, saga.id

        # If no identifier was given, one should be generated
        saga.id.should be_a(String)
        saga.correlations.should include(correlation)
        expect(saga.active?).to be_true
      end

      it 'supports deletion of a correlation' do
        saga = StubSaga.new

        key = :order_id
        value = '512d5467'

        saga.cause_correlate key, value
        saga.correlations.should include(Correlation.new(key, value))

        saga.cause_dissociate key, value
        saga.correlations.should_not include(Correlation.new(key, value))
      end

      it 'can be marked as finished' do
        saga = StubSaga.new
        saga.cause_finish

        expect(saga.active?).to be_false
      end
    end

  end
end
