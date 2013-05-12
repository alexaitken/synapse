require 'test_helper'
require 'domain/fixtures'

module Synapse
  module Repository
    class PessimisticLockManagerTest < Test::Unit::TestCase
      def test_lifecycle
        @manager = PessimisticLockManager.new

        aggregate = Domain::Person.new SecureRandom.uuid, 'Bender'

        refute @manager.validate_lock aggregate

        @manager.obtain_lock aggregate.id
        assert @manager.validate_lock aggregate
        @manager.release_lock aggregate.id
      end
    end
  end
end
