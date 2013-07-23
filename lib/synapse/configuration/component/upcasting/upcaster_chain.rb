module Synapse
  module Configuration
    # Definition builder used to create an upcaster chain
    #
    # Note that order is very important when building an upcaster chain; the container maintains
    # order when upcasters are registered as service definitions.
    #
    # @example The minimum possible effort to build an upcaster chain
    #   upcaster_chain
    #
    # @example Create an upcaster chain using a different identifier and properties
    #   upcaster_chain :alt_upcaster_chain do
    #     use_converter_factory :alt_converter_factory
    #     use_upcaster_tag :alt_upcaster
    #   end
    #
    # @example Register an upcaster that will be picked up by an upcaster chain
    #   factory :administrative_details_upcaster, :tag => :upcaster do
    #     AdministrativeDetailsUpcaster.new
    #   end
    class UpcasterChainDefinitionBuilder < DefinitionBuilder
      # Changes the converter factory
      #
      # @see Serialization::ConverterFactory
      # @param [Symbol] converter_factory
      # @return [undefined]
      def use_converter_factory(converter_factory)
        @converter_factory = converter_factory
      end

      # Changes the tag to use to automatically register upcasters
      #
      # @see Upcasting::Upcaster
      # @param [Symbol] upcaster_tag
      # @return [undefined]
      def use_upcaster_tag(upcaster_tag)
        @upcaster_tag = upcaster_tag
      end

      protected

      # @return [undefined]
      def populate_defaults
        identified_by :upcaster_chain

        use_converter_factory :converter_factory
        use_upcaster_tag :upcaster

        use_factory do
          converter_factory = resolve @converter_factory
          upcasters = resolve_tagged @upcaster_tag

          Upcasting::UpcasterChain.new converter_factory, upcasters
        end
      end
    end # UpcasterChainDefinitionBuilder
  end # Configuration
end
