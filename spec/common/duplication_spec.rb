require 'spec_helper'

module Synapse
  describe DuplicationRecorder do
    before do
      @recorder = DuplicationRecorder.new
      @message = Message.build
    end

    it 'raises an exception when a message is recorded more than once' do
      @recorder.recorded?(@message).should be_false

      @recorder.record @message
      @recorder.recorded?(@message).should be_true

      expect {
        @recorder.record @message
      }.to raise_error(DuplicationError)
    end

    it 'supports forgetting a message' do
      @recorder.record @message
      @recorder.forget @message

      @recorder.recorded?(@message).should be_false
    end

    it 'support pruning old messages' do
      @recorder.record @message

      threshold = 60 * 20 # 20 minutes

      Timecop.freeze(Time.now + 3600) do
        @recorder.forget_older_than Time.now - threshold
      end

      @recorder.recorded?(@message).should be_false
    end
  end
end
