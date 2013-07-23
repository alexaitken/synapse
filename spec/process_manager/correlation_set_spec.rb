require 'spec_helper'

module Synapse
  module ProcessManager

    describe CorrelationSet do
      it 'tracks correlation additions' do
        id = SecureRandom.uuid
        correlation = Correlation.new :order_id, id

        set = CorrelationSet.new
        set.add correlation
        set.add correlation

        set.should include(correlation)
        set.count.should == 1
        set.additions.count == 1

        set.commit
        set.delete correlation
        set.add correlation

        set.count.should == 1
        set.additions.count.should == 0
        set.deletions.count.should == 0
      end

      it 'tracks correlation deletions' do
        id = SecureRandom.uuid
        correlation = Correlation.new :order_id, id

        set = CorrelationSet.new
        set.add correlation
        set.delete correlation

        set.count.should == 0
        set.additions.count.should == 0
        set.deletions.count.should == 0

        set.add correlation
        set.commit
        set.delete correlation

        set.count.should == 0
        set.deletions.count.should == 1
      end
    end

  end
end
