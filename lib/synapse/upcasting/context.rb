module Synapse
  module Upcasting
    # Provides contextual information about an object being upcast; generally this is information
    # from the message containing the object to be upcast
    #
    # @abstract
    class UpcastingContext
      # @abstract
      # @return [String]
      def message_id; end

      # @abstract
      # @return [Hash]
      def metadata; end

      # @abstract
      # @return [Time]
      def timestamp; end

      # @abstract
      # @return [Object]
      def aggregate_id; end

      # @abstract
      # @return [Integer]
      def sequence_number; end
    end
  end
end
