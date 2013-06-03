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
      #
      # @see Serialization::AttributeSerializer
      # @return [undefined]
      def use_attribute
        @serializer_type = Serialization::AttributeSerializer
      end

      # Selects a serializer that uses the Ruby marshaling library
      #
      # @see Serialization::MarshalSerializer
      # @return [undefined]
      def use_marshal
        @serializer_type = Serialization::MarshalSerializer
      end

      # Selects a serializer that uses the Optimized JSON (Oj) serialization library
      #
      # @see Serialization::OjSerializer
      # @return [undefined]
      def use_oj
        @serializer_type = Serialization::OjSerializer
      end

      # Selects a serializer that uses the Optimized XML (Ox) serialization library
      #
      # @see Serialization::OxSerializer
      # @return [undefined]
      def use_ox
        @serializer_type = Serialization::OxSerializer
      end

      # Changes the converter factory
      #
      # @see Serialization::ConverterFactory
      # @param [Symbol] converter_factory
      # @return [undefined]
      def use_converter_factory(converter_factory)
        @converter_factory = converter_factory
      end

      # Changes the options to use during serialization; note that these are serializer-specific
      # and that not all serializers support options.
      #
      # @param [Hash] serialize_options
      # @return [undefined]
      def use_serialize_options(serialize_options)
        @serialize_options = serialize_options
      end

      # Changes the options to use during deserialization; note that these are serializer-specific
      # and that not all serializers support options.
      #
      # @param [Hash] deserialize_options
      # @return [undefined]
      def use_deserialize_options(deserialize_options)
        @deserialize_options = deserialize_options
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

          if @deserialize_options
            serializer.deserialize_options = @deserialize_options
          end

          serializer
        end
      end
    end # SerializerDefinitionBuilder
  end # Configuration
end
