require 'test_helper'
require 'atomic'

module Synapse
  module Command
    class AsynchronousCommandBusTest < Test::Unit::TestCase
      def setup
        unit_provider = UnitOfWork::UnitOfWorkProvider.new
        unit_factory = UnitOfWork::UnitOfWorkFactory.new unit_provider

        @bus = AsynchronousCommandBus.new unit_factory
        @bus.thread_pool = Thread.pool 2
      end

      def test_dispatch
        command = CommandMessage.as_message TestCommand.new
        callback = Object.new
        handler = TestAsyncHandler.new

        @bus.subscribe TestCommand, handler

        x = 10

        called_back = Atomic.new 0

        mock(callback).on_success(anything).any_times do
          called_back.update { |v| v.next }
        end

        x.times do
          @bus.dispatch_with_callback command, callback
        end

        wait_until do
          handler.count.value == x and called_back.value == x
        end

        @bus.shutdown
      end
    end

    class TestCommand; end

    class TestAsyncHandler
      attr_reader :count

      def initialize
        @count = Atomic.new 0
      end

      def handle(command, unit)
        @count.update { |v| v.next }
      end
    end
  end
end
