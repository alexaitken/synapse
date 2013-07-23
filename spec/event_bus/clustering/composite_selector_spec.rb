require 'spec_helper'

module Synapse
  module EventBus

    describe CompositeClusterSelector do
      it 'uses the selection from the first matching cluster selector' do
        cluster = Cluster.new

        selector_a = SimpleClusterSelector.new nil
        selector_b = SimpleClusterSelector.new cluster
        selector_c = SimpleClusterSelector.new nil

        listener = Object.new

        do_not_allow(selector_c).select_for(listener)

        selector = CompositeClusterSelector.new
        selector << selector_a << selector_b << selector_c
        selector.select_for(listener).should == cluster
      end
    end

  end
end
