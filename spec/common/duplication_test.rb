require 'test_helper'

module Synapse
  describe DuplicationRecorder do
    def setup
      @recorder = DuplicationRecorder.new
      @message = Message.build
    end

    should 'raise an exception when a message is recorded more than once' do
      refute @recorder.recorded? @message

      @recorder.record @message
      assert @recorder.recorded? @message

      assert_raise DuplicationError do
        @recorder.record @message
      end
    end

    should 'be able to forget a message' do
      @recorder.record @message
      @recorder.forget @message

      refute @recorder.recorded? @message
    end

    should 'be able to forget messages recorded before a certain time' do
      @recorder.record @message

      threshold = 60 * 20 # 20 minutes

      Timecop.freeze(Time.now + 3600) do
        @recorder.forget_older_than Time.now - threshold
      end

      refute @recorder.recorded? @message
    end
  end
end
