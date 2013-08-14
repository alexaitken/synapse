require 'spec_helper'

module Synapse
  module Event

    describe ClassPatternClusterSelector do
      it 'selects a cluster when the class name matches a pattern' do
        Foo = Class.new
        Bar = Class.new

        cluster = Object.new
        pattern = /Foo/

        selector = ClassPatternClusterSelector.new cluster, pattern

        selector.select_for(Foo.new).should be(cluster)
        selector.select_for(Bar.new).should be_nil
      end
    end

  end
end
