require 'spec_helper'

module Synapse
  module Saga

    describe CorrelationSet do
      let(:correlation) { Correlation.new :order_id, SecureRandom.uuid }

      it 'tracks correlation additions' do
        subject.add correlation
        subject.add correlation

        subject.should include(correlation)
        subject.count.should == 1
        subject.additions.count == 1

        subject.commit
        subject.delete correlation
        subject.add correlation

        subject.count.should == 1
        subject.additions.count.should == 0
        subject.deletions.count.should == 0
      end

      it 'tracks correlation deletions' do
        subject.add correlation
        subject.delete correlation

        subject.count.should == 0
        subject.additions.count.should == 0
        subject.deletions.count.should == 0

        subject.add correlation
        subject.commit
        subject.delete correlation

        subject.count.should == 0
        subject.deletions.count.should == 1
      end
    end

  end
end
