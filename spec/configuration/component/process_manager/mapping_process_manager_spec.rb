require 'spec_helper'
require 'process_manager/mapping/fixtures'

module Synapse
  module Configuration
    describe MappingProcessManagerDefinitionBuilder do

      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      it 'builds with sensible defaults' do
        @builder.factory :process_repository do
          ProcessManager::InMemoryProcessRepository.new
        end

        @builder.process_factory
        @builder.process_manager do
          use_process_types ProcessManager::OrderProcess
        end

        process_manager = @container.resolve :process_manager

        @container.resolve_tagged(:event_listener).should include(process_manager)

        factory = @container.resolve :process_factory
        repository = @container.resolve :process_repository

        process_manager.factory.should be(factory)
        process_manager.repository.should be(repository)
        process_manager.lock_manager.should be_a(ProcessManager::PessimisticLockManager)
      end

    end
  end
end
