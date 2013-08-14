require 'spec_helper'
require 'saga/routed/fixtures'

module Synapse
  module Saga

    describe RoutedSagaManager do
      let(:repository) { InMemorySagaRepository.new }
      let(:factory) { GenericSagaFactory.new }
      let(:lock_manager) { NullLockManager.new }

      subject {
        RoutedSagaManager.new repository, factory, lock_manager, OrderSaga
      }

      it 'raises an exception if used with a saga that does not support wiring' do
        expect {
          RoutedSagaManager.new repository, @factory, @lock_manager, Saga
        }.to raise_error ArgumentError
      end

      it 'uses mapping attributes to determine correlation keys' do
        event = create_event OrderCreated.new 123
        subject.notify event

        correlation = Correlation.new :order_id, 123

        sagas = repository.find OrderSaga, correlation
        sagas.size.should == 1
      end

      it 'uses mapping attributes to determine creation policy' do
        event = create_event OrderCreated.new 123

        subject.notify event
        subject.notify event

        repository.size.should == 1

        event = create_event OrderForceCreated.new 123

        subject.notify event
        subject.notify event

        repository.size.should == 3

        event = create_event OrderUpdated.new 123

        subject.notify event
        subject.notify event

        repository.size.should == 3
      end

     it 'raises an exception if the correlation key does not exist on the event' do
        event = create_event OrderDerped.new

        expect {
          subject.notify event
        }.to raise_error RuntimeError
      end

    private

      def create_event(payload)
        Event.build_message do |builder|
          builder.payload = payload
        end
      end
    end

  end
end
