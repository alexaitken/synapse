require 'spec_helper'

module Synapse
  module Serialization

    describe AttributeSerializer do
      subject do
        AttributeSerializer.new ConverterFactory.new
      end

      it 'supports serialization and deserialization of a hash' do
        content = {
          foo: 0
        }

        serialized_object = subject.serialize content, Hash

        serialized_object.content.should == content
        subject.deserialize(serialized_object).should == content

        subject.can_serialize_to?(Hash).should be_true
      end

      it 'supports serialization and deserialization of a compatible object' do
        content = SomeAttributeEvent.new 0

        attributes = {
          foo: 0
        }

        serialized_object = subject.serialize content, Hash

        serialized_object.content.should == attributes
        subject.deserialize(serialized_object).attributes.should == attributes
      end
    end

    class SomeAttributeEvent
      attr_accessor :attributes

      def initialize(some_value)
        @attributes = {
          foo: some_value
        }
      end
    end

  end
end
