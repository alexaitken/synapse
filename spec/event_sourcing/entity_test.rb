require 'spec_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe Entity do
      it 'raise an exception if an event is published and aggregate root is not set' do
        entity = StubEntity.new

        assert_raise RuntimeError do
          entity.change_something
        end

        aggregate = StubAggregate.new 123

        entity.aggregate_root = aggregate
        entity.change_something
      end

      it 'raise an exception if registration is attempted with more than one aggregate' do
        entity = StubEntity.new
        aggregate_a = StubAggregate.new 123
        aggregate_b = StubAggregate.new 123

        entity.aggregate_root = aggregate_a

        assert_raise RuntimeError do
          entity.aggregate_root = aggregate_b
        end
      end
    end

  end
end
