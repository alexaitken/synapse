require 'spec_helper'

module Synapse
  module Configuration

    describe ContainerResourceInjectorDefinitionBuilder do
      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      it 'builds a resource injector' do
        @builder.container_resource_injector

        resource_injector = @container.resolve :resource_injector
        resource_injector.should be_a(ProcessManager::ContainerResourceInjector)
      end
    end

  end
end
