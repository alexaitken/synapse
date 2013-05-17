module Synapse
  module Configuration
    # Definition builder used to create and configure serializers
    #
    # @example The minimum possible to create a serializer (defaults to marshal)
    #   serializer
    #
    # @example Use a specific serializer and converter_factory
    #   serializer :alt_serializer do
    #     use_ox
    #     use_converter_factory :alt_converter_factory
    #   end
    class SerializerDefinitionBuilder < DefinitionBuilder
      # Selects a serializer that uses attributes (ActiveModel, Virtus, etc.)
      # @return [undefined]
      def use_attribute
        @serializer_type = Serialization::AttributeSerializer
      end

      # Selects a serializer that uses the Ruby marshaling library
      # @return [undefined]
      def use_marshal
        @serializer_type = Serialization::MarshalSerializer
      end

      # Selects a serializer that uses the Optimized JSON (Oj) serialization library
      # @return [undefined]
      def use_oj
        @serializer_type = Serialization::OjSerializer
      end

      # Selects a serializer that uses the Optimized XML (Ox) serialization library
      # @return [undefined]
      def use_ox
        @serializer_type = Serialization::OxSerializer
        @serialize_options = {
          circular: true
        }
      end

      # Changes the converter factory
      #
      # @param [Symbol] converter_factory
      # @return [undefined]
      def use_converter_factory(converter_factory)
        @converter_factory = converter_factory
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :serializer

        use_marshal
        use_converter_factory :converter_factory

        use_factory do
          converter_factory = resolve @converter_factory
          serializer = @serializer_type.new converter_factory

          if @serialize_options
            serializer.serialize_options = @serialize_options
          end

          serializer
        end
      end
    end # SerializerDefinitionBuilder
  end # Configuration
end