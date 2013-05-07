module Synapse
  module ProcessManager
    # Represents a mechanism for managing long-running business transactions
    #
    # Processes are instances that handle events and may possibly produce new commands or have other
    # side effects. Multiple instances of a single type of process may exist. In that case, each
    # process will be managing a different transaction. Processes some way of correlating themselves
    # with relevant events. For example, if a process is associated with a specific order, it would
    # correlate itself with the order's identifier.
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
      # @param [Symbol] key
      # @param [String] value
      # @return [undefined]
      def correlate_with(key, value)
        @correlations.add(Correlation.new(key, value))
      end

      # Dissociates this process instance from the given key and value
      #
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
