module Synapse::EventStore::Mongo
  # Included for namespace aliasing purposes
  include Synapse::Domain
  include Synapse::EventStore

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

  class CursorDomainEventStream < DomainEventStream
    # @param [StorageStrategy] storage_strategy
    # @param [Mongo::DBCursor] cursor
    # @param [Array] last_snapshot_commit
    # @param [Object] aggregate_id
    # @return [undefined]
    def initialize(storage_strategy, cursor, last_snapshot_commit, aggregate_id)
      @storage_strategy = storage_strategy
      @cursor = cursor
      @aggregate_id = aggregate_id

      if last_snapshot_commit
        # Current batch is an enumerator
        @current_batch = last_snapshot_commit.each
      else
        @current_batch = [].each
      end

      initialize_next_event
    end

    # @return [Boolean]
    def end?
      @next.nil?
    end

    # @return [DomainEventMessage]
    def next_event
      current = @next
      initialize_next_event
      current
    end

    # @return [DomainEventMessage]
    def peek
      @next
    end

  private

    # @return [undefined]
    def initialize_next_event
      begin
        @next = @current_batch.next
      rescue StopIteration
        if @cursor.has_next?
          document = @cursor.next
          @current_batch = @storage_strategy.extract_events(document, @aggregate_id).each

          retry
        else
          @next = nil
        end
      end
    end
  end
end
