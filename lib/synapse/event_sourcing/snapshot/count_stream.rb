module Synapse
  module EventSourcing
    # Event stream decorator that simply counts each event that is retrieved from a delegate stream
    class CountingEventStream < Domain::DomainEventStream
      # @param [DomainEventStream] delegate
      # @param [Atomic] counter
      # @return [undefined]
      def initialize(delegate, counter)
        @delegate = delegate
        @counter = counter
      end

      # @return [Boolean]
      def end?
        @delegate.end?
      end

      # @return [DomainEventMessage]
      def next_event
        next_event = @delegate.next_event

        @counter.update do |value|
          value = value.next
        end

        next_event
      end

      # @return [DomainEventMessage]
      def peek
        @delegate.peek
      end
    end

    # Event stream decorator that counts each event retrieved from the delegate stream and
    # registers a listener with the current unit of work that can trigger a snapshot after the
    # unit of work has been cleaned up
    class TriggeringEventStream < CountingEventStream
      # @param [DomainEventStream] delegate
      # @param [Atomic] counter
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [EventCountSnapshotTrigger] trigger
      # @return [undefined]
      def initialize(delegate, counter, type_identifier, aggregate_id, trigger)
        super delegate, counter

        @type_identifier = type_identifier
        @aggregate_id = aggregate_id
        @trigger = trigger
      end

      # @return [Boolean]
      def end?
        the_end = @delegate.end?

        if the_end
          listener = SnapshotUnitOfWorkListener.new @type_identifier, @aggregate_id, @counter, @trigger

          unit = @trigger.unit_provider.current
          unit.register_listener listener

          @trigger.clear_counter @aggregate_id
        end

        the_end
      end
    end

    # Unit of work listener that is used to trigger snapshots after a unit of work has been cleaned up
    class SnapshotUnitOfWorkListener < UnitOfWork::UnitOfWorkListener
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [Atomic] counter
      # @param [EventCountSnapshotTrigger] trigger
      # @return [undefined]
      def initialize(type_identifier, aggregate_id, counter, trigger)
        @type_identifier = type_identifier
        @aggregate_id = aggregate_id
        @trigger = trigger
        @counter = counter
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_cleanup(unit)
        @trigger.trigger_snapshot @type_identifier, @aggregate_id, @counter
      end
    end
  end
end