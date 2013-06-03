require 'thread/pool'

module Synapse
  module EventSourcing
    # Snapshot taker that defers snapshots to a background thread pool
    class DeferredSnapshotTaker < SnapshotTaker
      # @return [Thread::Pool]
      attr_accessor :thread_pool

      # @param [SnapshotTaker] delegate
      # @return [undefined]
      def initialize(delegate)
        @delegate = delegate

        @deferred = Set.new
        @mutex = Mutex.new
      end

      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @return [undefined]
      def schedule_snapshot(type_identifier, aggregate_id)
        @mutex.synchronize do
          return if @deferred.include? aggregate_id
          @deferred.add aggregate_id
        end

        @thread_pool.push do
          @delegate.schedule_snapshot type_identifier, aggregate_id
          @deferred.delete aggregate_id
        end
      end

      # Shuts down the snapshot taker, waiting until all tasks are finished
      #
      # @api public
      # @return [undefined]
      def shutdown
        @thread_pool.shutdown
      end

      # Shuts down the snapshot taker without waiting for tasks to finish
      #
      # @api public
      # @return [undefined]
      def shutdown!
        @thread_pool.shutdown!
      end
    end # DeferredSnapshotTaker
  end # EventSourcing
end
