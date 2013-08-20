require 'spec_helper'

module Synapse
  module Command

    describe FutureCallback do
      it 'stores the result of the execution until accessed' do
        result = Object.new

        subject.on_success result
        subject.result.should == result
      end

      it 'raises an exception when accessed if the execution failed' do
        exception = NonTransientError.new

        subject.on_failure exception
        expect {
          subject.result
        }.to raise_error exception
      end
    end

  end
end
