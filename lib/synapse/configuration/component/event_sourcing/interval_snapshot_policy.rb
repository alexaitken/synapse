module Synapse
  module Configuration
    # Definition builder used to create an interval-based snapshot policy
    #
    # @example The minimum possible effort to build a snapshot policy
    #   interval_snapshot_policy
    #
    # @example Build an aggregate snapshot taker using an alternate threshold
    #   interval_snapshot_policy :alt_snapshot_policy do
    #     use_threshold 50
    #   end
    class IntervalSnapshotPolicyDefinitionBuilder < DefinitionBuilder
      # @param [Integer] threshold
      # @return [undefined]
      def use_threshold(threshold)
        @threshold = threshold
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :snapshot_policy

        use_threshold 30

        use_factory do
          EventSourcing::AggregateSnapshotTaker.new @threshold
        end
      end
    end # IntervalSnapshotPolicyDefinitionBuilder
  end # Configuration
end
