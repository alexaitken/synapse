module Synapse
  module ProcessManager
    # Combination key and value that is used to correlate incoming events with process instances
    class Correlation
      # @return [Symbol]
      attr_reader :key

      # @return [String]
      attr_reader :value

      # @param [Symbol] key
      # @param [String] value
      # @return [undefined]
      def initialize(key, value)
        @key = key.to_sym
        @value = value.to_s
      end

      def ==(other)
        self.class === other and
          other.key == @key and
          other.value == @value
      end

      alias eql? ==

      def hash
        @key.hash ^ @value.hash
      end
    end
  end
end
