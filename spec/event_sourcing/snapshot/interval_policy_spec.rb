require 'spec_helper'

module Synapse
  module EventSourcing

    describe IntervalSnapshotPolicy do
      it 'suggests a snapshot if the threshold is surpassed' do
        aggregate_a = Object.new
        aggregate_b = Object.new

        stub(aggregate_a).initial_version { nil }
        stub(aggregate_a).version { 35 }
        stub(aggregate_b).initial_version { 0 }
        stub(aggregate_b).version { 20 }

        policy = IntervalSnapshotPolicy.new 30

        policy.should_snapshot?(aggregate_a).should be_true
        policy.should_snapshot?(aggregate_b).should be_false
      end
    end

  end
end
