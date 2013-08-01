module Synapse
  module Saga
    # Sagaes are used to maintain the state of long-running business transactions
    # @abstract
    class Saga
      # @return [String] The unique identifier of this saga
      attr_reader :id

      # @return [CorrelationSet] The correlations for this saga
      attr_reader :correlations

      # @return [Boolean] True if this saga is active
      attr_reader :active

      alias_method :active?, :active

      # @param [String] id
      # @return [undefined]
      def initialize(id = nil)
        @id = id ||= IdentifierFactory.instance.generate
        @correlations = CorrelationSet.new
        @active = true

        correlate_with :saga_id, id
      end

      # Handles the given event
      #
      # The actual result of the sagaing depends on the implementation of the saga.
      # Implementations are highly discouraged from throwing exceptions.
      #
      # @abstract
      # @param [EventMessage] event
      # @return [undefined]
      def handle(event)
        raise NotImplementedError
      end

      protected

      # Correlates this saga instance with the given key and value
      #
      # @api public
      # @param [Symbol] key
      # @param [String] value
      # @return [undefined]
      def correlate_with(key, value)
        @correlations.add(Correlation.new(key, value))
      end

      # Dissociates this saga instance from the given key and value
      #
      # @api public
      # @param [Symbol] key
      # @param [String] value
      # @return [undefined]
      def dissociate_from(key, value)
        @correlations.delete(Correlation.new(key, value))
      end

      # Marks this saga as finished
      # @return [undefined]
      def finish
        @active = false
      end
    end # Saga
  end # Saga
end
