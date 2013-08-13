require 'spec_helper'

module Synapse
  module Router

    describe MessageHandler do
      context 'when using a block as a handler' do
        it 'invokes the block in the context of the subject' do
          subject = TestSubject.new
          message = Message.build do |builder|
            builder.payload = :test
          end
          block = proc { |payload, timestamp|
            self.should == subject

            payload.should == message.payload
            timestamp.should == message.timestamp
          }

          handler = MessageHandler.new subject.class, Symbol, block, Hash.new
          handler.invoke subject, message
        end

        it 'falls back to a simple parameter set without auto-resolve' do
          subject = TestSubject.new
          message = Message.build do |builder|
            builder.payload = :test
          end
          block = proc { |payload, message|
            self.should == subject

            payload.should == message.payload
            message.should == message
          }

          options = Hash[:auto_resolve, false]

          handler = MessageHandler.new subject.class, Symbol, block, options
          handler.invoke subject, message
        end
      end

      context 'when using a method as a handler' do
        it 'invokes the method on the subject' do
          subject = TestSubject.new
          message = Message.build do |builder|
            builder.payload = :test
          end

          handler = MessageHandler.new subject.class, Symbol, :test_method, Hash.new
          handler.invoke subject, message
        end

        it 'falls back to a simple parameter set without auto-resolve' do
          subject = TestSubject.new
          message = Message.build do |builder|
            builder.payload = :test
          end

          options = Hash[:auto_resolve, false]

          handler = MessageHandler.new subject.class, Symbol, :test_method, options
          handler.invoke subject, message

          handler = MessageHandler.new subject.class, Symbol, :test_method_adv, options
          handler.invoke subject, message
        end
      end

      it 'matches based on payload type' do
        message_a = Message.build do |builder|
          builder.payload = :hello_world
        end
        message_b = Message.build do |builder|
          builder.payload = "hello, world"
        end

        handler = MessageHandler.new TestSubject, Symbol, :test_method, Hash.new
        expect(handler.matches?(message_a)).to be_true
        expect(handler.matches?(message_b)).to be_false
      end

      it 'supports comparison of different handlers' do
        h = :test_method
        o = Hash.new

        handler = proc { |subject_type, payload_type|
          MessageHandler.new subject_type, payload_type, :test_method, Hash.new
        }

        handler[TestSubject, TestPayload].should == handler[TestSubject, TestPayload]
        handler[TestSubject, TestPayload].hash.should == handler[TestSubject, TestPayload].hash

        # Subject type depth
        handler[TestSubSubject, TestPayload].should < handler[TestSubject, TestPayload]
        handler[TestSubSubject, TestPayload].hash.should_not == handler[TestSubject, TestPayload].hash

        # Payload type depth
        handler[TestSubject, TestSubPayload].should < handler[TestSubject, TestPayload]

        # Payload + subject type depth
        handler[TestSubSubject, TestSubPayload].should < handler[TestSubject, TestPayload]

        # Payload name
        handler[TestSubject, TestPayload].should < handler[TestSubject, TestAscPayload]
      end
    end

    class TestSubject
      attr_accessor :invoked

      def initialize
        @invoked = 0
      end

      def test_method(payload)
        @invoked += 1
      end

      def test_method_adv(payload, message)
        @invoked += 1
      end
    end

    class TestSubSubject < TestSubject; end

    class TestPayload; end
    class TestSubPayload < TestPayload; end

    class TestAscPayload; end

  end
end
