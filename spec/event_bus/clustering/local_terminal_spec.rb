require 'spec_helper'

module Synapse
  module EventBus

    describe LocalEventBusTerminal do
      it 'publishes events to all known clusters' do
        cluster_a = Object.new
        cluster_b = Object.new

        event = Object.new

        mock(cluster_a).publish(event).once.ordered
        mock(cluster_b).publish(event).once.ordered

        subject.on_cluster_creation cluster_a
        subject.on_cluster_creation cluster_b

        subject.publish event
      end
    end

  end
end
