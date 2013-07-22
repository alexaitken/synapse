require 'spec_helper'
require 'process_manager/mapping/fixtures'

module Synapse
  module ProcessManager

    describe MappingProcessManager do
      before do
        @repository = InMemoryProcessRepository.new
        @factory = GenericProcessFactory.new
        @lock_manager = LockManager.new

        @manager = MappingProcessManager.new @repository, @factory, @lock_manager, OrderProcess
      end

      it 'raise an exception if used with a process that does not support wiring' do
        assert_raise ArgumentError do
          MappingProcessManager.new @repository, @factory, @lock_manager, Process
        end
      end

      it 'use mapping attributes to determine correlation keys' do
        event = create_event OrderCreated.new 123
        @manager.notify event

        correlation = Correlation.new :order_id, 123

        processes = @repository.find OrderProcess, correlation
        assert_equal 1, processes.count
      end

      it 'use mapping attributes to determine creation policy' do
        event = create_event OrderCreated.new 123

        @manager.notify event
        @manager.notify event

        assert_equal 1, @repository.count

        event = create_event OrderForceCreated.new 123

        @manager.notify event
        @manager.notify event

        assert_equal 3, @repository.count

        event = create_event OrderUpdated.new 123

        @manager.notify event
        @manager.notify event

        assert_equal 3, @repository.count
      end

     it 'raise an exception if the correlation key does not exist on the event' do
        event = create_event OrderDerped.new

        assert_raise RuntimeError do
          @manager.notify event
        end
      end

    private

      def create_event(payload)
        Domain::EventMessage.build do |builder|
          builder.payload = payload
        end
      end
    end

  end
end
