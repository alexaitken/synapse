require 'spec_helper'
require 'saga/fixtures'

module Synapse
  module Saga

    describe GenericSagaFactory do
      it 'creates new sagas' do
        injector = Object.new

        mock(injector).inject_resources(is_a(StubSaga))

        factory = GenericSagaFactory.new
        factory.resource_injector = injector

        saga = factory.create StubSaga
        saga.should be_a(StubSaga)
      end

      it 'can determine if a saga implementation is supported' do
        factory = GenericSagaFactory.new
        factory.supports(StubSaga).should be_true
        factory.supports(StubSagaWithArguments).should be_false
      end
    end

    class StubSagaWithArguments < Saga
      def initialize(some_resource); end
    end

  end
end
