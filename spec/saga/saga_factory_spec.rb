require 'spec_helper'
require 'saga/fixtures'

module Synapse
  module Saga

    describe GenericSagaFactory do
      it 'creates new sagas' do
        injector = Object.new
        subject.resource_injector = injector

        mock(injector).inject_into(is_a(StubSaga))

        subject.create(StubSaga).should be_a(StubSaga)
      end

      it 'can determine if a saga implementation is supported' do
        subject.support?(StubSaga).should be_true
        subject.support?(StubSagaWithArguments).should be_false
      end
    end

    class StubSagaWithArguments < Saga
      def initialize(some_resource); end
    end

  end
end
