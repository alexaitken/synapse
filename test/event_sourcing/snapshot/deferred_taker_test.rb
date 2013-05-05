require 'test_helper'

module Synapse
  module EventSourcing

    class DeferredSnapshotTakerTest < Test::Unit::TestCase
      def test_schedule_snapshot
        delegate = Object.new

        mock(EventMachine).defer.yields
        mock(delegate).schedule_snapshot 'test', 123

        snapshot_taker = DeferredSnapshotTaker.new delegate
        snapshot_taker.schedule_snapshot 'test', 123
      end
    end

  end
end
