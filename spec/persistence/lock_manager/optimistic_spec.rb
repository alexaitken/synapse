require 'spec_helper'
require 'event_sourcing/stub_aggregate'

module Synapse
  module Persistence

    describe OptimisticLockManager do
      it 'fails to validate on concurrent modification' do
        id = SecureRandom.uuid

        aggregate1 = EventSourcing::StubAggregate.new id
        aggregate2 = EventSourcing::StubAggregate.new id

        subject.obtain_lock aggregate1.id
        subject.obtain_lock aggregate2.id

        aggregate1.do_something
        aggregate2.do_something

        subject.validate_lock(aggregate1).should be_true
        subject.validate_lock(aggregate2).should be_false
      end

      it 'cleans up unused locks' do
        id = SecureRandom.uuid

        subject.obtain_lock id
        subject.obtain_lock id
        subject.release_lock id
        subject.release_lock id

        locks = subject.instance_variable_get :@locks
        expect(locks.key?(id)).to be_false
      end
    end

  end
end
