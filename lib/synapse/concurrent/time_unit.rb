module Synapse
  module Concurrent
    module TimeUnit
      extend self

      # @param [Float] interval
      # @return [Float]
      def nanoseconds(interval)
        interval / 1_000_000_000
      end

      # @param [Float] interval
      # @return [Float]
      def microseconds(interval)
        interval / 1_000_000
      end

      # @param [Float] interval
      # @return [Float]
      def milliseconds(interval)
        interval / 1_000
      end

      # @param [Float] interval
      # @return [Float]
      def seconds(interval)
        interval
      end
    end # TimeUnit
  end # Concurrent
end
