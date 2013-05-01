require 'test_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    class EntityTest < Test::Unit::TestCase
      def test_aggregate_root
        entity = StubEntity.new
        aggregate_a = StubAggregate.new 123
        aggregate_b = StubAggregate.new 123

        assert_raise RuntimeError do
          entity.change_something
        end

        entity.aggregate_root = aggregate_a

        assert_raise RuntimeError do
          entity.aggregate_root = aggregate_b
        end
      end

      def test_apply
        entity = StubEntity.new

        assert_raise RuntimeError do
          entity.change_something
        end
      end
    end

  end
end
