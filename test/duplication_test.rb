require 'test_helper'

module Synapse
  class DuplicationRecorderTest < Test::Unit::TestCase
    def setup
      @recorder = DuplicationRecorder.new
      @message = Message.build
    end

    def test_record
      refute @recorder.recorded? @message

      @recorder.record @message
      assert @recorder.recorded? @message

      assert_raise DuplicationError do
        @recorder.record @message
      end
    end

    def test_forget
      @recorder.record @message
      @recorder.forget @message

      refute @recorder.recorded? @message
    end

    def test_forget_older_than
      @recorder.record @message

      threshold = 60 * 20 # 20 minutes

      Timecop.freeze(Time.now + 3600) do
        @recorder.forget_older_than Time.now - threshold
      end

      refute @recorder.recorded? @message
    end
  end
end
