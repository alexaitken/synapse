require 'test_helper'

module Synapse
  module ProcessManager

    class ContainerResourceInjectorTest < Test::Unit::TestCase
      should 'use a service container to inject resources' do
        container = Object.new
        resource_injector = ContainerResourceInjector.new container
        process = Process.new

        mock(container).inject_into(process)

        resource_injector.inject_resources process
      end
    end

  end
end
