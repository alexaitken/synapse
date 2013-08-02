require 'spec_helper'

module Synapse
  module UnitOfWork

    describe UnitOfWorkFactory do
      it 'creates a unit of work and starts it' do
        provider = UnitOfWorkProvider.new
        factory = UnitOfWorkFactory.new provider

        uow = factory.create

        uow.should be_started
        uow.should_not be_transactional
      end

      it 'creates a unit of work with a transaction manager and starts it' do
        provider = UnitOfWorkProvider.new
        txm = Object.new
        factory = UnitOfWorkFactory.new provider
        factory.transaction_manager = txm

        mock(txm).start {
          Object.new
        }

        uow = factory.create

        uow.should be_started
        uow.should be_transactional
      end
    end

  end
end
