require 'spec_helper'
require 'configuration/fixtures/dependent'

module Synapse
  module Configuration

    describe Dependent do
      it 'creates accessors for injectable attributes' do
        dependent = ExampleDependent.new

        service_a = Object.new
        service_b = Object.new

        dependent.service_a = service_a
        dependent.some_service = service_b

        dependent.service_a.should be(service_a)
        dependent.some_service.should be(service_b)
      end

      it 'tracks which services to inject in which attributes' do
        dependencies = ExampleDependent.dependencies

        dependencies.fetch(:service_a).should == :service_a
        dependencies.fetch(:service_b).should == :some_service
      end
    end

  end
end
