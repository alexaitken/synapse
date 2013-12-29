module Synapse
  module EventSourcing

    class IncompatibleStubAggregate
      include AggregateRoot

      def change_something
        apply StubChangedEvent.new
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

    class StubAggregate
      include AggregateRoot

      attr_accessor :stub_entity, :stub_entities, :event_count
      members :stub_entity, :stub_entities

      def initialize(id = nil)
        pre_initialize
        id ||= SecureRandom.uuid
        apply StubCreatedEvent.new id
      end

      def do_something
        apply StubChangedEvent.new
      end

      def delete
        apply StubDeletedEvent.new
      end

    protected

      def pre_initialize
        @event_count = 0
        @stub_entities = []
      end

      route_event StubCreatedEvent do |event|
        @id = event.id
      end

      route_event StubDeletedEvent do |event|
        mark_deleted
      end

      def handle_event(event)
        super
        @event_count = @event_count.next
      end
    end

    class StubEntity
      include Entity

      attr_reader :event_count

      def initialize
        @event_count = 0
      end

      def do_something
        apply StubChangedEvent.new
      end

    protected

      def handle_event(event)
        @event_count = @event_count.next
      end
    end

  end
end

