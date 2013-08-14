require 'spec_helper'
require 'saga/fixtures'

module Synapse
  module Saga

    describe InMemorySagaRepository do
      it 'supports finding sagas by correlations' do
        correlation_a = Correlation.new :order_id, 1
        correlation_b = Correlation.new :order_id, 2

        saga_a = StubSaga.new
        saga_a.correlations.add correlation_a
        saga_b = StubSaga.new
        saga_b.correlations.add correlation_b

        subject.add saga_a
        subject.add saga_b

        subject.find(StubSaga, correlation_a).should include(saga_a.id)
        subject.find(StubSaga, correlation_b).should include(saga_b.id)
      end

      it 'supports loading sagas by identifier' do
        saga_a = StubSaga.new
        saga_b = StubSaga.new

        subject.add saga_a
        subject.add saga_b

        subject.load(saga_a.id).should == saga_a
        subject.load(saga_b.id).should == saga_b
      end

      it 'marks sagas as committed' do
        saga = StubSaga.new
        subject.commit saga

        subject.size.should == 1

        # Make sure the correlation set was marked as committed
        saga.correlations.additions.size.should == 0
        saga.correlations.deletions.size.should == 0

        saga.cause_finish

        subject.commit saga
        subject.size.should == 0
      end
    end

  end
end
