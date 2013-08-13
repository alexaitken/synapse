require 'spec_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe Entity do
      it 'raises an exception if an event is published and aggregate root is not set' do
        entity = StubEntity.new

        expect {
          entity.do_something
        }.to raise_error InvalidStateError

        aggregate = StubAggregate.new 123

        entity.aggregate_root = aggregate
        entity.do_something
      end

      it 'raises an exception if registration is attempted with more than one aggregate' do
        entity = StubEntity.new
        aggregate_a = StubAggregate.new 123
        aggregate_b = StubAggregate.new 123

        entity.aggregate_root = aggregate_a

        expect {
          entity.aggregate_root = aggregate_b
        }.to raise_error InvalidStateError
      end
    end

  end
end

