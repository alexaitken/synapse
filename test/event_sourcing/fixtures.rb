module Synapse
  module EventSourcing

    class IncompatibleStubAggregate
      include AggregateRoot

      def change_something
        apply StubChangedEvent.new
      end
    end

    class StubAggregate
      include AggregateRoot

      attr_accessor :stub_entity, :stub_entities, :event_count
      child_entity :stub_entity, :stub_entities

      def initialize(id)
        pre_initialize
        apply StubCreatedEvent.new id
      end

      def change_something
        apply StubChangedEvent.new
      end

      def delete_me
        apply StubDeletedEvent.new
      end

    protected

      def pre_initialize
        @event_count = 0
        @stub_entities = Array.new
      end

      def handle_event(event)
        payload = event.payload
        type = event.payload_type

        if type.eql? StubCreatedEvent
          @id = payload.id
        elsif type.eql? StubDeletedEvent
          mark_deleted
        end

        @event_count = @event_count.next
      end
    end

    class StubEntity
      include Entity

      attr_reader :event_count

      def initialize
        @event_count = 0
      end

      def change_something
        apply StubChangedEvent.new
      end

    protected

      def handle_event(event)
        @event_count = @event_count.next
      end
    end

    class StubCreatedEvent
      attr_reader :id

      def initialize(id)
        @id = id
      end
    end

    class StubDeletedEvent; end

    class StubChangedEvent; end

  end
end