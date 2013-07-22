require 'spec_helper'
require 'process_manager/mapping/fixtures'

module Synapse
  module ProcessManager

    describe MappingProcess do
      before do
        @process = OrderProcess.new
      end

      it 'use the correct handler when notified of an event' do
        event = Domain::EventMessage.build do |builder|
          builder.payload = OrderCreated.new 123
        end

        @process.handle event

        assert_equal 1, @process.handled
      end

      it 'use mapping attributes to determine when to mark itself as finished' do
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
