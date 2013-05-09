module Synapse
  module EventSourcing
    # Represents a mechanism that is capable of detecting conflicts between applied changes
    # to the aggregate and unseen changes made to the aggregate.
    class ConflictResolver
      # Checks the list of changes applied to the aggregate and compares it to the list of
      # events already applied to the aggregate. If a conflict is detected, this should throw
      # an exception. Otherwise, the changes will be applied.
      #
      # @raise [ConflictingModificationException] If any conflicts were detected
      # @param [Array] applied_changes List of changes applied to the aggregate
      # @param [Array] committed_changes List of events that were unexpected by the command handler
      # @return [undefined]
      def resolve_conflicts(applied_changes, committed_changes); end
    end

    # Unit of work listener that detects if there is a conflict before an aggregate is committed
    # If there is a potential conflict, a conflict resolver determines how to resolve the conflict.
    class ConflictResolvingUnitOfWorkListener < UnitOfWork::UnitOfWorkListener
      # @param [AggregateRoot] aggregate
      # @param [Array] unseen_events
      # @param [ConflictResolver] conflict_resolver
      # @return [undefined]
      def initialize(aggregate, unseen_events, conflict_resolver)
        @aggregate = aggregate
        @unseen_events = unseen_events
        @conflict_resolver = conflict_resolver
      end

      # @param [UnitOfWork] unit
      # @param [Array<AggregateRoot>] aggregates
      # @param [Hash<EventBus, Array>] events
      # @return [undefined]
      def on_prepare_commit(unit, aggregates, events)
        if potential_conflicts?
          @conflict_resolver.resolve_conflicts @aggregate.uncommitted_events.to_a, @unseen_events
        end
      end

    private

      # @return [Boolean]
      def potential_conflicts?
        @aggregate.uncommitted_event_count > 0 and
          @aggregate.version and
          @unseen_events.size > 0
      end
    end

    # Event stream decorator that captures any events that have been applied after the expected
    # version of an aggregate
    class CapturingEventStream < Domain::DomainEventStream
      extend Forwardable

      # @param [DomainEventStream] delegate
      # @param [Array] unseen_events
      # @param [Integer] expected_version
      # @return [undefined]
      def initialize(delegate, unseen_events, expected_version)
        @delegate = delegate
        @unseen_events = unseen_events
        @expected_version = expected_version
      end

      # @return [DomainEventMessage]
      def next_event
        @delegate.next_event.tap do |event|
          if @expected_version and event.sequence_number > @expected_version
            @unseen_events.push event
          end
        end
      end

      # Delegators for domain event stream
      def_delegators :@delegate, :end?, :peek
    end
  end
end
