require 'spec_helper'
require 'process_manager/fixtures'

module Synapse
  module ProcessManager

    describe GenericProcessFactory do
      it 'creates new processes' do
        injector = Object.new

        mock(injector).inject_resources(is_a(StubProcess))

        factory = GenericProcessFactory.new
        factory.resource_injector = injector

        process = factory.create StubProcess
        process.should be_a(StubProcess)
      end

      it 'be able to determine if a process implementation is supported' do
        factory = GenericProcessFactory.new
        factory.supports(StubProcess).should be_true
        factory.supports(StubProcessWithArguments).should be_false
      end
    end

    class StubProcessWithArguments < Process
      def initialize(some_resource); end
    end

  end
end
