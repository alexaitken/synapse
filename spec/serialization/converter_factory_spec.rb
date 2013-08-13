require 'spec_helper'

module Synapse
  module Serialization

    describe ConverterFactory do
      it 'returns an identity converter if the source/target type are the same' do
        subject.has_converter?(String, String).should be_true
        subject.converter(String, String).should be_an(IdentityConverter)
      end

      it 'returns a converter matching a source/target type' do
        subject.has_converter?(Object, String).should be_false

        expect {
          subject.converter(Object, String)
        }.to raise_error ConversionError

        converter = ObjectToJsonConverter.new
        subject.register converter

        subject.has_converter?(Object, String).should be_true
        subject.converter(Object, String).should == converter
      end
    end

  end
end

