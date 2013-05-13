require 'test_helper'

module Synapse
  module Wiring

    class WireRegistryTest < Test::Unit::TestCase
      def test_duplicates
        registry = WireRegistry.new false

        registry.register Wire.new Object, Hash.new, :test
        registry.register Wire.new Integer, Hash.new, :test

        assert_raise DuplicateWireError do
          registry.register Wire.new Object, Hash.new, :test
        end
      end

      def test_each_type
        registry = WireRegistry.new false

        registry.register Wire.new Integer, Hash.new, :test
        registry.register Wire.new Object, Hash.new, :test

        types = Array.new
        registry.each_type do |type|
          types << type
        end

        assert_equal [Integer, Object], types
      end

      def test_wire_for
        registry = WireRegistry.new false

        registry.register Wire.new Object, Hash.new, :test
        registry.register Wire.new Integer, Hash.new, :test

        wire = registry.wire_for Integer
        assert_equal Integer, wire.type

        wire = registry.wire_for BasicObject
        assert_equal nil, wire
      end

      def test_wires_for
        registry = WireRegistry.new false

        registry.register Wire.new String, Hash.new, :test
        registry.register Wire.new Object, Hash.new, :test
        registry.register Wire.new Integer, Hash.new, :test

        wires = registry.wires_for Integer

        assert_equal Integer, wires[0].type
        assert_equal Object, wires[1].type
      end
    end

  end
end
