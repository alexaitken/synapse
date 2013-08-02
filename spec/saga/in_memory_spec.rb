require 'spec_helper'
require 'saga/fixtures'

module Synapse
  module Saga

    describe InMemorySagaRepository do
      it 'supports finding sagas by correlations' do
        correlation_a = Correlation.new :order_id, 1
        correlation_b = Correlation.new :order_id, 2

        saga_a = Saga.new
        saga_a.correlations.add correlation_a
        saga_b = Saga.new
        saga_b.correlations.add correlation_b

        repository = InMemorySagaRepository.new
        repository.add saga_a
        repository.add saga_b

        repository.find(Saga, correlation_a).should include(saga_a.id)
        repository.find(Saga, correlation_b).should include(saga_b.id)
      end

      it 'supports loading sagas by identifier' do
        repository = InMemorySagaRepository.new

        saga_a = Saga.new
        saga_b = Saga.new

        repository.add saga_a
        repository.add saga_b

        repository.load(saga_a.id).should == saga_a
        repository.load(saga_b.id).should == saga_b
      end

      it 'marks sagas as committed' do
        repository = InMemorySagaRepository.new

        saga = StubSaga.new
        repository.commit saga

        repository.size.should == 1

        # Make sure the correlation set was marked as committed
        saga.correlations.additions.size.should == 0
        saga.correlations.deletions.size.should == 0

        saga.cause_finish

        repository.commit saga
        repository.size.should == 0
      end
    end

  end
end
