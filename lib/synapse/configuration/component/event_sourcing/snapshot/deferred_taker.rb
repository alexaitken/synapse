module Synapse
  module Configuration
    # Definition builder used to create a deferred snapshot taker
    #
    # @example The minimum possible effort to build a deferred snapshot taker
    #   deferred_snapshot_taker do
    #     use_snapshot_taker :some_snapshot_taker
    #   end
    #
    # @example Build a deferred snapshot taker with a custom thread count
    #   deferred_snapshot_taker do
    #     use_snapshot_taker :some_snapshot_taker
    #     use_threads 2, 4
    #   end
    #
    # @example Defer an aggregate snapshot taker
    #   aggregate_snapshot_taker :delegate_snapshot_taker
    #   deferred_snapshot_taker do
    #     use_snapshot_taker :delegate_snapshot_taker
    #   end
    class DeferredSnapshotTakerDefinitionBuilder < DefinitionBuilder
      include ThreadPoolDefinitionBuilder

      # Changes the snapshot taker that will be deferred
      #
      # @see EventSourcing::SnapshotTaker
      # @param [Symbol] snapshot_taker
      # @return [undefined]
      def use_snapshot_taker(snapshot_taker)
        @snapshot_taker = snapshot_taker
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :snapshot_taker

        use_threads 2

        use_factory do
          delegate = resolve @snapshot_taker

          snapshot_taker = EventSourcing::DeferredSnapshotTaker.new delegate
          snapshot_taker.thread_pool = create_thread_pool

          snapshot_taker
        end
      end
    end # DeferredSnapshotTakerDefinitionBuilder
  end # Configuration
end
