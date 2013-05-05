require 'atomic'

module Synapse
  module EventSourcing
    # Snapshot trigger that counts the number of events between snapshots to decide when to
    # schedule the next snapshot
    class EventCountSnapshotTrigger < EventStreamDecorator
      # @return [SnapshotTaker]
      attr_reader :snapshot_taker

      # @return [Integer] The number of events between snapshots
      attr_accessor :threshold

      # @return [UnitOfWorkProvider]
      attr_reader :unit_provider

      # @param [SnapshotTaker] snapshot_taker
      # @param [UnitOfWorkProvider] unit_provider
      # @return [undefined]
      def initialize(snapshot_taker, unit_provider)
        @counters = Hash.new
        @lock = Mutex.new
        @snapshot_taker = snapshot_taker
        @threshold = 50
        @unit_provider = unit_provider
      end

      # If the event threshold has been reached for the aggregate with the given identifier, this
      # will cause a snapshot to be scheduled
      #
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [Atomic] counter
      # @return [undefined]
      def trigger_snapshot(type_identifier, aggregate_id, counter)
        if counter.value > @threshold
          logger.debug 'Snapshot threshold reached for [%s] [%s]' % [type_identifier, aggregate_id]

          @snapshot_taker.schedule_snapshot type_identifier, aggregate_id
          counter.value = 1
        end
      end

      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [DomainEventStream] stream
      # @return [DomainEventStream]
      def decorate_for_read(type_identifier, aggregate_id, stream)
        CountingEventStream.new(stream, counter_for(aggregate_id))
      end

      # @param [String] type_identifier
      # @param [AggregateRoot] aggregate
      # @param [DomainEventStream] stream
      # @return [DomainEventStream]
      def decorate_for_append(type_identifier, aggregate, stream)
        TriggeringEventStream.new(stream, counter_for(aggregate.id), type_identifier, aggregate.id, self)
      end

      # Returns the event counter for the aggregate with the given identifier
      #
      # @param [Object] aggregate_id
      # @return [Atomic]
      def counter_for(aggregate_id)
        @lock.synchronize do
          if @counters.has_key? aggregate_id
            @counters.fetch aggregate_id
          else
            @counters.store aggregate_id, Atomic.new(0)
          end
        end
      end

      # Clears the event counter for the aggregate with the given identifier
      #
      # @param [Object] aggregate_id
      # @return [undefined]
      def clear_counter(aggregate_id)
        @lock.synchronize do
          @counters.delete aggregate_id
        end
      end

    private

      # @return [Logger]
      def logger
        @logger ||= Logging.logger[self.class]
      end
    end
  end
end
