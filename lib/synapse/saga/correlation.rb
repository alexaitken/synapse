module Synapse
  module Saga
    # Combination key and value that is used to correlate incoming events with saga instance
    class Correlation
      include Adamantium
      include Equalizer.new(:key, :value)

      # @return [Symbol]
      attr_reader :key

      # @return [String]
      attr_reader :value

      # @param [Symbol] key
      # @param [String] value
      def initialize(key, value)
        @key = key.to_sym
        @value = value.to_s
      end
    end # Correlation
  end # Saga
end
