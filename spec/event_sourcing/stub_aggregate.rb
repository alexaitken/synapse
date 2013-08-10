require 'spec_helper'

module Synapse
  module EventSourcing

    class StubAggregate
      include AggregateRoot

      attr_reader :id
      attr_reader :invocation_count

      def initialize(id = nil)
        pre_initialize
        @id = id || SecureRandom.uuid
      end

      def do_something
        apply StubDomainEvent.new
      end

      def delete
        apply StubDomainEvent.new
        mark_deleted
      end

      protected

      def pre_initialize
        @invocation_count = 0
      end

      def handle_event(event)
        @id = event.aggregate_id
        @invocation_count += 1
      end

      def child_entities
        []
      end
    end

    class StubDomainEvent; end

  end
end
