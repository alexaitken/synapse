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
        saga.should be_active
      end

      it 'supports deletion of a correlation' do
        saga = StubSaga.new

        correlation = Correlation.new :order_id, SecureRandom.uuid

        saga.cause_correlate correlation.key, correlation.value
        saga.correlations.should include(correlation)

        saga.cause_dissociate correlation.key, correlation.value
        saga.correlations.should_not include(correlation)
      end

      it 'can be marked as finished' do
        saga = StubSaga.new
        saga.cause_finish

        saga.should_not be_active
      end
    end

  end
end
