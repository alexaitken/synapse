require 'test_helper'
require 'process_manager/wiring/fixtures'

module Synapse
  module ProcessManager

    class WiringProcessTest < Test::Unit::TestCase
      def setup
        @process = OrderProcess.new
      end

      def test_handle
        event = Domain::EventMessage.build do |builder|
          builder.payload = OrderCreated.new 123
        end

        @process.handle event

        assert_equal 1, @process.handled
      end

      def test_handle_finish
        event = Domain::EventMessage.build do |builder|
          builder.payload = OrderCanceled.new 123
        end

        @process.handle event

        assert_equal 1, @process.handled
        refute @process.active?
      end
    end

  end
end
