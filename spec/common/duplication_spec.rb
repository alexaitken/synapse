require 'spec_helper'

module Synapse
  describe DuplicationRecorder do
    subject do
      DuplicationRecorder.new
    end

    let :message do
      Message.build
    end

    it 'raises an exception when a message is recorded more than once' do
      subject.recorded?(message).should be_false

      subject.record message
      subject.recorded?(message).should be_true

      expect {
        subject.record message
      }.to raise_error DuplicationError
    end

    it 'supports forgetting a message' do
      subject.record message
      subject.forget message

      subject.recorded?(message).should be_false
    end

    it 'supports pruning old messages' do
      subject.record message

      threshold = 60 * 20 # 20 minutes

      Timecop.freeze(Time.now + 3600) do
        subject.forget_older_than Time.now - threshold
      end

      subject.recorded?(message).should be_false
    end
  end
end
