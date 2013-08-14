module Synapse
  module Event
    class BaseCluster < Cluster
      include AbstractType

      # @return [String]
      attr_reader :name

      # @return [ClusterMetadata]
      attr_reader :metadata

      # @param [String] name
      # @return [undefined]
      def initialize(name)
        @name = name

        @metadata = ClusterMetadata.new
        @members = Contender::CopyOnWriteSet.new
      end

      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        @members.add listener
      end

      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        @members.delete listener
      end

      # @return [Set]
      def members
        @members.to_set
      end
    end # BaseCluster
  end # Event
end
