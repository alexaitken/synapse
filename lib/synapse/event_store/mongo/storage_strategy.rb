module Synapse
  module EventStore
    module Mongo
      # Represents a mechanism used to structure how events are stored in the database
      # @abstract
      class StorageStrategy
        # @param [MongoTemplate] template
        # @param [Serializer] serializer
        # @param [UpcasterChain] upcaster_chain
        # @return [undefined]
        def initialize(template, serializer, upcaster_chain)
          @template = template
          @serializer = Serialization::MessageSerializer.new serializer
          @upcaster_chain = upcaster_chain
        end

        # Creates documents that will represent the events being committed to the event store
        #
        # @abstract
        # @param [String] type_identifier Type identifier for the aggregate
        # @param [Array] events Domain events to be committed
        # @return [Array]
        def create_documents(type_identifier, events); end

        # Extracts individual event messages from the given document
        #
        # The given aggregate identifier is passed so that event messages can have the actual
        # identifier object instead of the serialized aggregate identifier.
        #
        # @abstract
        # @param [Hash] document
        # @param [Object] aggregate_id
        # @return [Array]
        def extract_events(document, aggregate_id); end

        # Aliases of the Mongo constants for ascending and descending
        ASCENDING = ::Mongo::ASCENDING
        DESCENDING = ::Mongo::DESCENDING

        # Provides a cursor for accessing all events for an aggregate with the given identifier
        # and type identifier, with a sequence number equal to or greater than the given first
        # sequence number
        #
        # The returned documents should be ordered chronologically, typically by using the
        # sequence number.
        #
        # @param [String] type_identifier
        # @param [Object] aggregate_id
        # @param [Integer] first_sequence_number
        # @return [Mongo::Cursor]
        def fetch_events(type_identifier, aggregate_id, first_sequence_number)
          filter = {
            aggregate_id: aggregate_id,
            aggregate_type: type_identifier,
            sequence_number: {
              '$gte' => first_sequence_number
            }
          }

          sort = {
            sequence_number: ASCENDING
          }

          @template.event_collection.find(filter).sort(sort)
        end

        # Finds the document containing the most recent snapshot event for an aggregate with the
        # given identifier and type identifier
        #
        # @param [String] type_identifier
        # @param [Object] aggregate_id
        # @return [Mongo::Cursor]
        def fetch_last_snapshot(type_identifier, aggregate_id)
          filter = {
            aggregate_id: aggregate_id,
            aggregate_type: type_identifier
          }

          sort = {
            sequence_number: DESCENDING
          }

          @template.snapshot_collection.find(filter).sort(sort).limit(1)
        end

        # Ensures that the correct indexes are in place
        # @return [undefined]
        def ensure_indexes
          options = {
            name: 'unique_aggregate_index',
            unique: true
          }

          spec = {
            aggregate_id: ASCENDING,
            aggregate_type: ASCENDING,
            sequence_number: ASCENDING
          }

          @template.event_collection.ensure_index spec, options

          spec = {
            aggregate_id: ASCENDING,
            aggregate_type: ASCENDING,
            sequence_number: DESCENDING
          }

          @template.snapshot_collection.ensure_index spec, options
        end
      end # StorageStrategy
    end # Mongo
  end # EventStore
end # Synapse
