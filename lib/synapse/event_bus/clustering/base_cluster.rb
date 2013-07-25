module Synapse
  module EventBus
    # @abstract
    class BaseCluster < Cluster
      # @return [String]
      attr_reader :name

      # @return [Set]
      attr_reader :members

      # @return [Hash]
      attr_reader :metadata

      # @param [String] name
      # @return [undefined]
      def initialize(name)
        @name = name
        @metadata = Hash.new
        # @todo This should be a thread-safe structure
        @members = Set.new
      end

      # @api public
      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        @members.add listener
      end

      # @api public
      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        @members.delete listener
      end
    end # BaseCluster
  end # EventBus
end
