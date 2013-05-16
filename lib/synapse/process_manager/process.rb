module Synapse
  module ProcessManager
    # Processes are used to maintain the state of long-running business transactions
    #
    # The term process is used in Enterprise Integration Patterns to describe a mechanism used to
    # "maintain the state of the sequence and determine the next processing step based on
    # intermediate results" (Hohpe 279). Processes are also called sagas in some CQRS frameworks.
    #
    # Consider using the implementation of a process that uses message wiring.
    #
    # @abstract
    class Process
      # @return [String] The unique identifier of this process
      attr_reader :id

      # @return [CorrelationSet] The correlations for this process
      attr_reader :correlations

      # @return [Boolean] True if this process is active
      attr_reader :active

      alias active? active

      # @param [String] id
      # @return [undefined]
      def initialize(id = nil)
        unless id
          id = IdentifierFactory.instance.generate
        end

        @id = id
        @correlations = CorrelationSet.new
        @active = true

        correlate_with :process_id, id
      end

      # Handles the given event
      #
      # The actual result of the processing depends on the implementation of the process.
      # Implementations are highly discouraged from throwing exceptions.
      #
      # @abstract
      # @param [EventMessage] event
      # @return [undefined]
      def handle(event); end

    protected

      # Correlates this process instance with the given key and value
      #
      # @api public
      # @param [Symbol] key
      # @param [String] value
      # @return [undefined]
      def correlate_with(key, value)
        @correlations.add(Correlation.new(key, value))
      end

      # Dissociates this process instance from the given key and value
      #
      # @api public
      # @param [Symbol] key
      # @param [String] value
      # @return [undefined]
      def dissociate_from(key, value)
        @correlations.delete(Correlation.new(key, value))
      end

      # Marks this process as finished
      # @return [undefined]
      def finish
        @active = false
      end
    end
  end
end
