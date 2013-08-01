require 'spec_helper'

module Synapse
  module Saga

    describe ContainerResourceInjector do
      it 'uses a service container to inject resources' do
        container = Object.new
        resource_injector = ContainerResourceInjector.new container
        saga = Saga.new

        mock(container).inject_into(saga)

        resource_injector.inject_resources saga
      end
    end

  end
end
