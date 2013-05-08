require 'test_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    class SnapshotIntegrationTest < Test::Unit::TestCase
      def test_integration
        unit_provider = Object.new
        unit = Object.new

        mock(unit_provider).current do
          unit
        end

        listener = nil

        mock(unit).register_listener(is_a(SnapshotUnitOfWorkListener)) do |l|
          listener = l
        end

        event_store = Object.new

        aggregate_id = 123
        type_identifier = Object.to_s

        aggregate = Object.new
        mock(aggregate).id.any_times do
          aggregate_id
        end

        snapshot_taker = Object.new
        snapshot_trigger = EventCountSnapshotTrigger.new snapshot_taker, unit_provider
        snapshot_trigger.threshold = 5

        read_stream = create_stream 3
        append_stream = create_stream 3

        decorated_read_stream = snapshot_trigger.decorate_for_read type_identifier, aggregate_id, read_stream
        decorated_read_stream.to_a # Causes stream to iterate over all events

        decorated_append_stream = snapshot_trigger.decorate_for_append type_identifier, aggregate, append_stream
        decorated_append_stream.to_a # Ditto

        # At this point, there is a snapshot unit of work listener added
        # Let's "cleanup" the unit of work and check if the snapshot is triggered

        mock(snapshot_taker).schedule_snapshot type_identifier, aggregate_id

        listener.on_cleanup unit
      end

      def create_stream(size)
        events = Array.new

        size.times do
          events.push Domain::DomainEventMessage.build
        end

        Domain::SimpleDomainEventStream.new events
      end
    end

  end
end
