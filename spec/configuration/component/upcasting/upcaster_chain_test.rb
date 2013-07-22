module Synapse
  module Configuration
    describe UpcasterChainDefinitionBuilder do

      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with sensible defaults' do
        @builder.converter_factory
        @builder.factory :some_upcaster, :tag => :upcaster do
          Object.new
        end

        @builder.upcaster_chain

        converter_factory = @container.resolve :converter_factory
        some_upcaster = @container.resolve :some_upcaster

        upcaster_chain = @container.resolve :upcaster_chain

        assert_same converter_factory, upcaster_chain.converter_factory
        assert_includes upcaster_chain.upcasters, some_upcaster
      end

    end
  end
end
