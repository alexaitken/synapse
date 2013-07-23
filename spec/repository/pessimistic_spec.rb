require 'spec_helper'
require 'domain/fixtures'

module Synapse
  module Repository

    describe PessimisticLockManager do
      it 'supports obtaining and releasing a lock for an aggregate' do
        @manager = PessimisticLockManager.new

        aggregate = Domain::Person.new SecureRandom.uuid, 'Bender'

        @manager.validate_lock(aggregate).should be_false

        @manager.obtain_lock aggregate.id
        @manager.validate_lock(aggregate).should be_true
        @manager.release_lock aggregate.id
        @manager.validate_lock(aggregate).should be_false
      end
    end

  end
end
