module Synapse
  module EventSourcing
    # Snapshot taker that uses the actual aggregate and its state to create a snapshot event
    class AggregateSnapshotTaker < SnapshotTaker
      # @return [undefined]
      def initialize
        super
        @factories = ThreadSafe::Cache.new
      end

      # @param [AggregateFactory] factory
      # @return [undefined]
      def register_factory(factory)
        @factories.put factory.type_identifier, factory
      end

      protected

      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [DomainEventStream] stream
      # @return [DomainEventMessage]
      def create_snapshot(type_identifier, aggregate_id, stream)
        factory = @factories.fetch type_identifier

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
