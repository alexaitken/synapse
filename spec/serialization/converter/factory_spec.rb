require 'spec_helper'

module Synapse
  module Serialization

    describe ConverterFactory do
      before do
        @factory = ConverterFactory.new
      end

      it 'returns an identity converter if the source/target type are the same' do
        @factory.has_converter?(String, String).should be_true
        @factory.converter(String, String).should be_an(IdentityConverter)
      end

      it 'returns a converter matching a source/target type' do
        @factory.has_converter?(Object, String).should be_false

        expect {
          @factory.converter(Object, String)
        }.to raise_error(ConversionError)

        converter = ObjectToJsonConverter.new
        @factory.register converter

        @factory.has_converter?(Object, String).should be_true
        @factory.converter(Object, String).should == converter
      end
    end

  end
end
