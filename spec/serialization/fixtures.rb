require 'spec_helper'

module Synapse
  module Serialization
    class TestEvent
      include Equalizer.new(:a, :b)

      attr_reader :a, :b

      def initialize(a, b)
        @a, @b = a, b
      end
    end # TestEvent
  end # Serialization
end
