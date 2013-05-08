module Synapse
  module EventStore
    module Mongo
      # Implementation of an event store backed by a Mongo database
      class MongoEventStore < SnapshotEventStore
        # @param [MongoTemplate] template
        # @param [StorageStrategy] storage_strategy
        # @return [undefined]
        def initialize(template, storage_strategy)
          @storage_strategy = storage_strategy
          @template = template
        end

        # @return [undefined]
        def ensure_indexes
          @storage_strategy.ensure_indexes
        end

        # @raise [EventStoreError] If an error occurs while reading the stream from the store
        # @param [String] type_identifier Type descriptor of the aggregate to retrieve
        # @param [Object] aggregate_id
        # @return [DomainEventStream]
        def read_events(type_identifier, aggregate_id)
          first_sequence_number = -1

          last_snapshot_commit = load_last_snapshot type_identifier, aggregate_id
          if last_snapshot_commit and last_snapshot_commit.size > 0
            first_sequence_number = last_snapshot_commit[0].sequence_number
          end

          cursor = @storage_strategy.fetch_events type_identifier, aggregate_id, first_sequence_number

          unless last_snapshot_commit or cursor.has_next?
            raise StreamNotFoundError.new type_identifier, aggregate_id
          end

          CursorDomainEventStream.new @storage_strategy, cursor, last_snapshot_commit, aggregate_id
        end

        # @raise [EventStoreError] If an error occurs while appending the stream to the store
        # @param [String] type_identifier Type descriptor of the aggregate to append to
        # @param [DomainEventStream] stream
        # @return [undefined]
        def append_events(type_identifier, stream)
          events = stream.to_a
          documents = @storage_strategy.create_documents type_identifier, events

          begin
            @template.event_collection.insert documents
          rescue Mongo::OperationFailure => ex
            if e.error_code == 11000
              raise Repository::ConcurrencyException,
                'Event for this aggregate and sequence number already present'
            end

            raise ex
          end
        end

        # @raise [EventStoreError] If an error occurs while appending the event to the store
        # @param [String] type_identifier Type descriptor of the aggregate to append to
        # @param [DomainEventMessage] snapshot_event
        # @return [undefined]
        def append_snapshot_event(type_identifier, snapshot_event)
          documents = @storage_strategy.create_documents type_identifier, [snapshot_event]
          @template.snapshot_collection.insert documents
        end

      private

        # @param [String] type_identifier Type descriptor of the aggregate to retrieve
        # @param [Object] aggregate_id
        def load_last_snapshot(type_identifier, aggregate_id)
          cursor = @storage_strategy.fetch_last_snapshot type_identifier, aggregate_id

          unless cursor.has_next?
            return
          end

          first = cursor.next_document
          @storage_strategy.extract_events first, aggregate_id
        end
      end # MongoEventStore
    end # Mongo
  end # EventStore
end # Synapse
