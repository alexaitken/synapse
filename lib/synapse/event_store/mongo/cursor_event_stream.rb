module Synapse
  module EventStore
    module Mongo
      # TODO Document me
      class CursorDomainEventStream < Domain::DomainEventStream
        # @param [StorageStrategy] storage_strategy
        # @param [Mongo::Cursor] cursor
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
          @next.tap do
            initialize_next_event
          end
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
      end # CursorDomainEventStream
    end
  end
end
