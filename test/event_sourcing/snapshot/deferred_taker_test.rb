require 'test_helper'

module Synapse
  module EventSourcing
    class DeferredSnapshotTakerTest < Test::Unit::TestCase

      should 'defer snapshots to the background' do
        delegate = Object.new
        thread_pool = Object.new

        type_identifier = 'Order'
        aggregate_id = SecureRandom.uuid

        deferred_block = nil

        mock(delegate).schedule_snapshot(type_identifier, aggregate_id)

        mock(thread_pool).push.twice do |block|
          deferred_block = block
        end

        taker = DeferredSnapshotTaker.new delegate
        taker.thread_pool = thread_pool

        taker.schedule_snapshot type_identifier, aggregate_id
        taker.schedule_snapshot type_identifier, aggregate_id

        deferred_block.call

        taker.schedule_snapshot type_identifier, aggregate_id
      end

    end
  end
end
