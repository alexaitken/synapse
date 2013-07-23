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

      it 'raises an exception if used with a process that does not support wiring' do
        expect {
          MappingProcessManager.new @repository, @factory, @lock_manager, Process
        }.to raise_error(ArgumentError)
      end

      it 'uses mapping attributes to determine correlation keys' do
        event = create_event OrderCreated.new 123
        @manager.notify event

        correlation = Correlation.new :order_id, 123

        processes = @repository.find OrderProcess, correlation
        processes.count.should == 1
      end

      it 'uses mapping attributes to determine creation policy' do
        event = create_event OrderCreated.new 123

        @manager.notify event
        @manager.notify event

        @repository.count.should == 1

        event = create_event OrderForceCreated.new 123

        @manager.notify event
        @manager.notify event

        @repository.count.should == 3

        event = create_event OrderUpdated.new 123

        @manager.notify event
        @manager.notify event

        @repository.count.should == 3
      end

     it 'raises an exception if the correlation key does not exist on the event' do
        event = create_event OrderDerped.new

        expect {
          @manager.notify event
        }.to raise_error(RuntimeError)
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
