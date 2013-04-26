module Synapse
  module Serialization
    class TestEvent
      attr_reader :a, :b

      def initialize(a, b)
        @a, @b = a, b
      end

      def ==(other)
        self.class === other and
          other.a == @a and
          other.b == @b
      end
    end
  end
end
