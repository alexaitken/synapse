require 'test_helper'

module Synapse
  module Wiring

    class WireTest < Test::Unit::TestCase
      should 'support invoking instance methods' do
        payload = TestEvent.new

        target = Object.new
        mock(target).test(payload)

        wire = Wire.new TestEvent, Hash.new, :test
        wire.invoke target, payload
      end

      should 'support invoking procs' do
        payload = TestEvent.new

        target_class = Class.new do
          def initialize
            @secret = 5
          end
        end
        target = target_class.new

        handler = proc do |command|
          raise 'Oh noes' unless @secret == 5
        end

        wire = Wire.new TestEvent, Hash.new, handler
        wire.invoke target, payload
      end

      should 'determine equality and order with other wires' do
        wire_a = Wire.new TestEvent, Hash.new, :test
        wire_b = Wire.new TestEvent, Hash.new, :test
        wire_c = Wire.new TestSubEvent, Hash.new, :test

        assert wire_a == wire_b
        assert wire_b == wire_a
        assert_equal wire_a <=> wire_c, 1
        assert_equal wire_c <=> wire_a, -1
      end
    end

    class TestEvent; end
    class TestSubEvent < TestEvent; end

  end
end
