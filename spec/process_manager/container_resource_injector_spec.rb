require 'spec_helper'

module Synapse
  module ProcessManager

    describe ContainerResourceInjector do
      it 'uses a service container to inject resources' do
        container = Object.new
        resource_injector = ContainerResourceInjector.new container
        process = Process.new

        mock(container).inject_into(process)

        resource_injector.inject_resources process
      end
    end

  end
end
