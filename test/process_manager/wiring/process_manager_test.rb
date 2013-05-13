require 'test_helper'
require 'process_manager/wiring/fixtures'

module Synapse
  module ProcessManager

    class WiringProcessManagerTest < Test::Unit::TestCase
      def setup
        @repository = InMemoryProcessRepository.new
        @factory = GenericProcessFactory.new
        @lock_manager = LockManager.new

        @manager = WiringProcessManager.new @repository, @factory, @lock_manager, OrderProcess
      end

      def test_correlation
        event = create_event OrderCreated.new 123
        @manager.notify event

        correlation = Correlation.new :order_id, 123

        processes = @repository.find OrderProcess, correlation
        assert_equal 1, processes.count
      end

      def test_creation_policy
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

      def test_correlation_fails
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
