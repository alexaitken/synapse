require 'test_helper'

module Synapse
  module Command
    class DuplicationFilterTest < Test::Unit::TestCase
      def test_filter
        recorder = DuplicationRecorder.new
        filter = DuplicationFilter.new recorder

        command = CommandMessage.build

        result = filter.filter command

        assert_same command, result
        assert recorder.recorded? command
      end
    end

    class DuplicationCleanupInterceptorTest < Test::Unit::TestCase
      def test_intercept
        recorder = DuplicationRecorder.new
        interceptor = DuplicationCleanupInterceptor.new recorder

        command = CommandMessage.build
        unit = Object.new

        chain = Object.new
        mock(chain).proceed(command) do
          raise TransientError
        end

        recorder.record command

        assert_raise TransientError do
         interceptor.intercept command, unit, chain
        end

        refute recorder.recorded? command

        mock(chain).proceed(command) do
          raise ArgumentError
        end

        recorder.record command

        assert_raise ArgumentError do
         interceptor.intercept command, unit, chain
        end

        assert recorder.recorded? command
      end
    end
  end
end
