require 'spec_helper'
require 'domain/fixtures'

module Synapse
  module Repository

    describe OptimisticLockManager do
      it 'fails to validate on concurrent modification' do
        manager = OptimisticLockManager.new

        id = SecureRandom.uuid

        aggregate1 = Domain::Person.new id, 'Calculon'
        aggregate2 = Domain::Person.new id, 'Calculon'

        manager.obtain_lock aggregate1.id
        manager.obtain_lock aggregate2.id

        aggregate1.change_name 'Bender'
        aggregate2.change_name 'Amy'

        manager.validate_lock(aggregate1).should be_true
        manager.validate_lock(aggregate2).should be_false
      end

      it 'cleans up unused locks' do
        manager = OptimisticLockManager.new

        id = SecureRandom.uuid

        manager.obtain_lock id
        manager.obtain_lock id
        manager.release_lock id
        manager.release_lock id

        aggregates = manager.instance_variable_get :@aggregates
        aggregates.has_key?(id).should be_false
      end
    end

  end
end
