require 'test_helper'

module Synapse
  module Configuration
    class ContainerResourceInjectorDefinitionBuilderTest < Test::Unit::TestCase

      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build a resource injector' do
        @builder.container_resource_injector

        resource_injector = @container.resolve :resource_injector
        assert_instance_of ProcessManager::ContainerResourceInjector, resource_injector
      end

    end
  end
end
