require 'test_helper'
require 'process_manager/wiring/fixtures'

module Synapse
  module ProcessManager

    class WiringProcessTest < Test::Unit::TestCase
      def setup
        @process = OrderProcess.new
      end

      should 'use the correct handler when notified of an event' do
        event = Domain::EventMessage.build do |builder|
          builder.payload = OrderCreated.new 123
        end

        @process.handle event

        assert_equal 1, @process.handled
      end

      should 'use wiring attributes to determine when to mark itself as finished' do
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
