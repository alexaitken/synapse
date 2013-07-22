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

      should 'call initializers upon creation' do
        ContainerBuilder.initializer do
          definition :test_definition do
            tag :derp
          end
        end

        builder = ContainerBuilder.new @container

        assert @container.registered? :test_definition
      end

      should 'create a simple definition from a factory' do
        builder = ContainerBuilder.new @container
        builder.factory :derp_service, :tag => [:first_tag, :nth_tag] do
          123
        end

        assert @container.registered? :derp_service
        assert_equal 123, @container.resolve(:derp_service)
        assert_equal [123], @container.resolve_tagged(:first_tag)
        assert_equal [123], @container.resolve_tagged(:nth_tag)
      end
    end
  end
end
