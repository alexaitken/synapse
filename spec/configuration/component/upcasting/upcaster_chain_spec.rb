require 'spec_helper'

module Synapse
  module Configuration

    describe UpcasterChainDefinitionBuilder do
      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      it 'builds with sensible defaults' do
        @builder.converter_factory
        @builder.factory :some_upcaster, :tag => :upcaster do
          Object.new
        end

        @builder.upcaster_chain

        converter_factory = @container.resolve :converter_factory
        some_upcaster = @container.resolve :some_upcaster

        upcaster_chain = @container.resolve :upcaster_chain

        upcaster_chain.converter_factory.should be(converter_factory)
        upcaster_chain.upcasters.should include(some_upcaster)
      end
    end

  end
end
