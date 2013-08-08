require 'spec_helper'

module Synapse
  module Command

    describe SimpleCommandBus do
      after do
        CurrentUnit.rollback_all
      end

      it 'dispatches commands to their respective handlers' do
        handler = Object.new
        callback = Object.new
        result = Object.new

        command = CommandMessage.as_message :test

        mock(handler).handle(command, is_a(Unit)).returns(result)
        mock(callback).on_success(result)

        subject.subscribe Symbol, handler
        subject.dispatch_with_callback command, callback
      end

      it 'commits the implicit unit of work upon successful dispatch' do
        handler = Object.new
        callback = Object.new
        result = Object.new

        command = CommandMessage.as_message :test

        mock(handler).handle(command, is_a(Unit)) do
          unit = CurrentUnit.get
          unit.should be_active

          mock.proxy(unit).commit

          result
        end
        mock(callback).on_success(result)

        subject.subscribe Symbol, handler
        subject.dispatch_with_callback command, callback

        CurrentUnit.should_not be_active
      end

      it 'rolls back the implicit unit of work upon exception during dispatch' do
        handler = Object.new
        callback = Object.new
        exception = MockError.new

        command = CommandMessage.as_message :test

        mock(handler).handle(command, is_a(Unit)) do
          unit = CurrentUnit.get
          unit.should be_active

          mock.proxy(unit).rollback(exception)

          raise exception
        end
        mock(callback).on_failure(exception)

        subject.subscribe Symbol, handler
        subject.dispatch_with_callback command, callback

        CurrentUnit.should_not be_active
      end

      it 'commits the implicit unit of work upon exception using the rollback policy' do
        handler = Object.new
        callback = Object.new
        exception = MockError.new

        command = CommandMessage.as_message :test

        mock(handler).handle(command, is_a(Unit)) do
          unit = CurrentUnit.get
          unit.should be_active

          mock.proxy(unit).commit

          raise exception
        end
        mock(callback).on_failure(exception)

        rollback_policy = Object.new
        mock(rollback_policy).should_rollback?(exception).returns(false)

        subject.rollback_policy = rollback_policy
        subject.subscribe Symbol, handler
        subject.dispatch_with_callback command, callback

        CurrentUnit.should_not be_active
      end

      it 'fails to dispatch command without a subscribed handler' do
        expect {
          subject.dispatch(CommandMessage.as_message(:test))
        }.to raise_error NoHandlerError
      end

      it 'filters commands before dispatching them' do
        command = CommandMessage.as_message :test

        filter = Object.new
        mock(filter).filter(command) do
          command.and_metadata :foo => :bar
        end

        handler = Object.new
        callback = Object.new
        result = Object.new

        mock(handler).handle(anything, anything) do |command, _|
          command.metadata.should == Hash[:foo, :bar]
          result
        end

        mock(callback).on_success(result)

        subject.filters = [filter]
        subject.subscribe Symbol, handler
        subject.dispatch_with_callback command, callback
      end

      it 'aborts dispatch if a filter raises an exception' do
        command = CommandMessage.as_message :test

        filter = Object.new
        mock(filter).filter(command) do
          raise MockError
        end

        subject.filters = [filter]
        expect {
          subject.dispatch command
        }.to raise_error MockError
      end

      it 'replaces handlers when other handlers are subscribed for the same type' do
        handler_a = Object.new
        handler_b = Object.new

        subject.subscribe(Symbol, handler_a).should be_nil
        subject.subscribe(Symbol, handler_b).should == handler_a
      end

      it 'supports unsubscribing a command handler' do
        handler_a = Object.new
        handler_b = Object.new

        subject.unsubscribe(Symbol, handler_a).should be_false
        subject.subscribe(Symbol, handler_a)
        subject.unsubscribe(Symbol, handler_b).should be_false
        subject.unsubscribe(Symbol, handler_a).should be_true
      end

      CurrentUnit = UnitOfWork::CurrentUnit
      Unit = UnitOfWork::Unit
    end

    class MockError < RuntimeError; end

  end
end
