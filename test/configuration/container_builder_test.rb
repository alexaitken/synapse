require 'test_helper'

module Synapse
  module Configuration
    class ContainerBuilderTest < Test::Unit::TestCase
      def setup
        # Backup any existing initializers
        @initializers = ContainerBuilder.initializers
        ContainerBuilder.initializers = nil

        # Create a container that will be built
        @container = Container.new
      end

      def teardown
        # Restore any existing initializers
        ContainerBuilder.initializers = @initializers
      end

      def test_initializers
        ContainerBuilder.initializer do
          definition :test_definition do
            tag :derp
          end
        end

        builder = ContainerBuilder.new @container

        assert @container.registered? :test_definition
      end

      def test_factory
        builder = ContainerBuilder.new @container
        builder.build_with do
          factory :derp_service, :tag => [:first_tag, :nth_tag] do
            123
          end
        end

        assert @container.registered? :derp_service
        assert_equal 123, @container.resolve(:derp_service)
        assert_equal [123], @container.resolve_tagged(:first_tag)
        assert_equal [123], @container.resolve_tagged(:nth_tag)
      end
    end
  end
end
