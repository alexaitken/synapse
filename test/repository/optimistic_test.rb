require 'test_helper'
require 'domain/fixtures'

module Synapse
  module Repository
    class OptimisticLockManagerTest < Test::Unit::TestCase
      def test_fails_on_concurrent_modification
        manager = OptimisticLockManager.new

        id = SecureRandom.uuid

        aggregate1 = Domain::Person.new id, 'Calculon'
        aggregate2 = Domain::Person.new id, 'Calculon'

        manager.obtain_lock aggregate1.id
        manager.obtain_lock aggregate2.id


        aggregate1.change_name 'Bender'
        aggregate2.change_name 'Amy'

        assert manager.validate_lock aggregate1
        refute manager.validate_lock aggregate2
      end

      def test_lock_cleanup
        manager = OptimisticLockManager.new

        id = SecureRandom.uuid

        manager.obtain_lock id
        manager.obtain_lock id
        manager.release_lock id
        manager.release_lock id

        aggregates = manager.instance_variable_get :@aggregates
        refute aggregates.has_key? id
      end
    end
  end
end
