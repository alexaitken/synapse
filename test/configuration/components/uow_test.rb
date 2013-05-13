require 'test_helper'

module Synapse
  module Configuration

    class UnitOfWorkContainerBuilderTest < Test::Unit::TestCase
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      def test_default_provider
        provider = @container.fetch :unit_provider

        assert provider.is_a? UnitOfWork::UnitOfWorkProvider
      end

      def test_default_factory
        provider = @container.fetch :unit_provider
        factory = @container.fetch :unit_factory

        unit = factory.create

        assert_equal unit, provider.current
      end
    end

  end
end
