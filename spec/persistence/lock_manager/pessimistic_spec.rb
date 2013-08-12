require 'spec_helper'
require 'domain/fixtures'
require 'event_sourcing/stub_aggregate'

module Synapse
  module Persistence

    describe PessimisticLockManager do
      it 'supports obtaining and releasing a lock for an aggregate' do
        aggregate = EventSourcing::StubAggregate.new

        subject.validate_lock(aggregate).should be_false

        subject.obtain_lock aggregate.id
        subject.validate_lock(aggregate).should be_true
        subject.release_lock aggregate.id
        subject.validate_lock(aggregate).should be_false
      end
    end

  end
end
