require 'spec_helper'

module Synapse
  module EventBus

    describe ClusteringEventBus do
      it 'delegates publication to an event bus terminal' do
        terminal = Object.new

        cluster = SimpleCluster.new :default
        selector = SimpleClusterSelector.new cluster

        event = Object.new
        listener = Object.new

        mock(terminal).on_cluster_creation(cluster)
        mock(terminal).publish(event)

        bus = ClusteringEventBus.new selector, terminal
        bus.subscribe listener
        bus.publish event
      end

      it 'raises an error no cluster is selected for an event listener' do
        listener = Object.new

        selector = Object.new
        terminal = Object.new

        mock(selector).select_for(listener)

        bus = ClusteringEventBus.new selector, terminal

        expect {
          bus.subscribe listener
        }.to raise_error(SubscriptionError)
      end

      it 'only notifies the terminal of unknown clusters' do
        terminal = Object.new

        cluster = SimpleCluster.new :default
        selector = SimpleClusterSelector.new cluster

        listener = Object.new

        mock(terminal).on_cluster_creation(cluster).once

        bus = ClusteringEventBus.new selector, terminal
        bus.subscribe listener
        bus.subscribe listener
      end
    end

  end
end
