require 'test_helper'

module Synapse
  module Wiring
    class WireRegistryTest < Test::Unit::TestCase

      should 'raise an exception if two wires are registered for the same payload type' do
        registry = WireRegistry.new false

        registry.register Wire.new Object, Hash.new, :test
        registry.register Wire.new Integer, Hash.new, :test

        assert_raise DuplicateWireError do
          registry.register Wire.new Object, Hash.new, :test
        end
      end

      should 'return the payload types of types being registered' do
        registry = WireRegistry.new false

        registry.register Wire.new Integer, Hash.new, :test
        registry.register Wire.new Object, Hash.new, :test

        types = Array.new
        registry.each_type do |type|
          types << type
        end

        assert_equal [Integer, Object], types
      end

      should 'return a wire registered for a given payload type' do
        registry = WireRegistry.new false

        registry.register Wire.new Object, Hash.new, :test
        registry.register Wire.new Integer, Hash.new, :test

        wire = registry.wire_for Integer
        assert_equal Integer, wire.type

        wire = registry.wire_for BasicObject
        assert_equal nil, wire
      end

      should 'return all the wires registered for a given payload type' do
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
