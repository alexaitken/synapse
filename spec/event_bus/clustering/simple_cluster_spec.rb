require 'spec_helper'

module Synapse
  module EventBus

    describe SimpleCluster do
      subject do
        SimpleCluster.new :some_cluster_name
      end

      it 'initializes with the correct attributes' do
        subject.name.should == :some_cluster_name
        subject.metadata.should be_a ClusterMetadata
        subject.members.should be_empty
      end

      it 'publishes events to subscribed listeners' do
        listener = Object.new
        event = Object.new

        mock(listener).notify(event).once

        subject.publish event

        subject.subscribe listener
        subject.publish event

        subject.unsubscribe listener
        subject.publish event
      end
    end

  end
end
