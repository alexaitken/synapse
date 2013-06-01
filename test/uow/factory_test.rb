require 'test_helper'

module Synapse
  module UnitOfWork
    class UnitOfWorkFactoryTest < Test::Unit::TestCase
      should 'create a unit of work, set the transaction manager and start it' do
        provider = UnitOfWorkProvider.new
        txm = Object.new
        factory = UnitOfWorkFactory.new provider
        factory.transaction_manager = txm

        mock(txm).start {
          Object.new
        }

        uow = factory.create

        assert uow.started?
        assert uow.transactional?
      end
    end
  end
end
