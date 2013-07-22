require 'spec_helper'

module Synapse
  module UnitOfWork

    describe UnitOfWorkFactory do
      it 'creates a unit of work and starts it' do
        provider = UnitOfWorkProvider.new
        factory = UnitOfWorkFactory.new provider

        uow = factory.create

        expect(uow.started?).to be_true
        expect(uow.transactional?).to be_false
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

        expect(uow.started?).to be_true
        expect(uow.transactional?).to be_true

      end
    end

  end
end
