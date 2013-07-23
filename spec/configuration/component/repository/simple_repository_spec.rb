require 'spec_helper'

module Synapse
  module Configuration

    describe SimpleRepositoryDefinitionBuilder do
      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      it 'builds with sensible defaults' do
        # Repository needs unit of work provider (initialized by default)
        # Repository needs event bus
        @builder.simple_event_bus

        # SimpleRepository needs an aggregate type
        @builder.simple_repository :account_repository do
          use_aggregate_type Object
        end

        repository = @container.resolve :account_repository

        event_bus = @container.resolve :event_bus
        unit_provider = @container.resolve :unit_provider

        repository.event_bus.should be(event_bus)
        repository.unit_provider.should be(unit_provider)

        repository.lock_manager.should be_a(Repository::PessimisticLockManager)
      end
    end

  end
end
