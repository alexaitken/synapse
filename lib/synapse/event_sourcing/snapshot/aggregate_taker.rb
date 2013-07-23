module Synapse
  module EventSourcing
    # Snapshot taker that uses the actual aggregate and its state to create a snapshot event
    class AggregateSnapshotTaker < SnapshotTaker
      # @return [undefined]
      def initialize
        super
        # @todo This should be a thread-safe structure
        @aggregate_factories = Hash.new
      end

      # @param [AggregateFactory] factory
      # @return [undefined]
      def register_factory(factory)
        @aggregate_factories.store factory.type_identifier, factory
      end

      protected

      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [DomainEventStream] stream
      # @return [DomainEventMessage]
      def create_snapshot(type_identifier, aggregate_id, stream)
        factory = @aggregate_factories.fetch type_identifier

        aggregate = factory.create_aggregate aggregate_id, stream.peek
        aggregate.initialize_from_stream stream

        Domain::DomainEventMessage.build do |builder|
          builder.payload = aggregate
          builder.aggregate_id = aggregate.id
          builder.sequence_number = aggregate.version
        end
      end
    end # AggregateSnapshotTaker
  end # EventSourcing
end
