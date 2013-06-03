require 'test_helper'

module Synapse
  module Serialization

    class ConverterFactoryTest < Test::Unit::TestCase

      def setup
        @factory = ConverterFactory.new
      end

      should 'return an identity converter if the source/target type are the same' do
        assert @factory.has_converter?(String, String)
        assert @factory.converter(String, String).is_a?(IdentityConverter)
      end

      should 'return a converter matching a source/target type' do
        refute @factory.has_converter?(Object, String)

        assert_raise ConversionError do
          @factory.converter(Object, String)
        end

        converter = ObjectToJsonConverter.new
        @factory.register converter

        assert @factory.has_converter?(Object, String)
        assert_equal converter, @factory.converter(Object, String)
      end
    end

  end
end
