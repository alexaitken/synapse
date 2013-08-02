require 'spec_helper'

module Synapse
  module Command

    describe DuplicationFilter do
      it 'records commands so that duplication can be detected' do
        recorder = DuplicationRecorder.new
        filter = DuplicationFilter.new recorder

        command = CommandMessage.build

        result = filter.filter command

        result.should be(command)
        recorder.recorded?(command).should be_true
      end
    end

    describe DuplicationCleanupInterceptor do
      it 'forgets recorded commands if a transient error occurs' do
        recorder = DuplicationRecorder.new
        interceptor = DuplicationCleanupInterceptor.new recorder

        command = CommandMessage.build
        unit = Object.new

        chain = Object.new
        mock(chain).proceed(command) do
          raise TransientError
        end

        recorder.record command

        expect {
          interceptor.intercept command, unit, chain
        }.to raise_error TransientError

        recorder.recorded?(command).should be_false

        ExampleError = Class.new RuntimeError

        mock(chain).proceed(command) do
          raise ExampleError
        end

        recorder.record command

        expect {
          interceptor.intercept command, unit, chain
        }.to raise_error ExampleError

        recorder.recorded?(command).should be_true
      end
    end

  end
end
