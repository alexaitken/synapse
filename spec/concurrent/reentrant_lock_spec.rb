require 'spec_helper'

module Synapse
  module Concurrent

    describe ReentrantLock do
      it 'supports recursive locking' do
        subject.should_not be_owned
        subject.should_not be_locked

        subject.lock
        subject.lock

        subject.should be_owned
        subject.hold_count.should == 2

        subject.unlock

        subject.should be_owned
        subject.hold_count.should == 1

        subject.unlock

        subject.should_not be_owned
        subject.should_not be_locked
      end

      CountdownLatch = Contender::CountdownLatch
    end

  end
end
