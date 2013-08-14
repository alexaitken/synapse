require 'spec_helper'

module Synapse
  module Saga

    describe SimpleSagaManager do
      let(:repository) { InMemorySagaRepository.new }
      let(:factory) { GenericSagaFactory.new }
      let(:correlation_resolver) { MetadataCorrelationResolver.new :order_id }
      let(:lock_manager) { Object.new }

      subject {
        SimpleSagaManager.new repository, factory, lock_manager, correlation_resolver, TestSaga
      }

      it 'acts as an event listener proxy' do
        subject.proxied_type.should == TestSaga
      end

      it 'creates a new saga and notify it if one could not be found' do
        subject.optionally_create_events = Set[CauseSagaCreationEvent]

        correlation = Correlation.new :order_id, 123

        mock(lock_manager).obtain_lock(is_a(String))
        mock(lock_manager).release_lock(is_a(String))

        subject.notify create_event 123, CauseSagaCreationEvent.new

        repository.size.should == 1
      end

      it 'loads and notifies an existing saga correlated with an event' do
        saga = TestSaga.new
        saga.correlations.add Correlation.new :order_id, 123

        repository.add saga

        mock(lock_manager).obtain_lock(saga.id)
        mock(lock_manager).release_lock(saga.id)

        subject.notify create_event 123, CauseSagaNotificationEvent.new

        repository.size.should == 1
      end

      it 'suppresses exceptions raised by a saga while handling an event' do
        saga = TestSaga.new
        saga.correlations.add Correlation.new :order_id, 123

        repository.add saga

        mock(lock_manager).obtain_lock(saga.id)
        mock(lock_manager).release_lock(saga.id)

        subject.notify create_event 123, CauseSagaRaiseExceptionEvent.new

        repository.size.should == 1
      end

      it 'releases its lock before raising an exception caused by a saga' do
        saga = TestSaga.new
        saga.correlations.add Correlation.new :order_id, 123

        repository.add saga

        mock(lock_manager).obtain_lock(saga.id)
        mock(lock_manager).release_lock(saga.id)

        subject.suppress_exceptions = false

        expect {
          subject.notify create_event 123, CauseSagaRaiseExceptionEvent.new
        }.to raise_error RuntimeError
      end

      it 'always creates a saga if specified by the creation policy' do
        subject.always_create_events = Set[CauseSagaCreationEvent]

        correlation = Correlation.new :order_id, 123

        # Lock is obtain/released for the 2 being created and once for the first being changed
        mock(lock_manager).obtain_lock(is_a(String)).times(3)
        mock(lock_manager).release_lock(is_a(String)).times(3)

        subject.notify create_event 123, CauseSagaCreationEvent.new
        subject.notify create_event 123, CauseSagaCreationEvent.new

        repository.size.should == 2
      end

    private

      def create_event(order_id, event)
        Event.build_message do |builder|
          builder.payload = event
          builder.metadata = Hash[:order_id, order_id]
        end
      end
    end

    # Example correlation resolver
    class MetadataCorrelationResolver < CorrelationResolver
      def initialize(property)
        @property = property
      end

      def resolve(event)
        value = event.metadata[@property]
        if value
          Correlation.new @property, value
        end
      end
    end

    # Test saga that has all sorts of trigger events
    class TestSaga < Saga
      attr_accessor :handled

      def handle(event)
        if event.payload_type == CauseSagaRaiseExceptionEvent
          raise 'ohgodimnotgoodwithcomputers'
        end

        @handled ||= 0
        @handled = @handled.next
      end
    end

    class CauseSagaCreationEvent; end
    class CauseSagaNotificationEvent; end
    class CauseSagaRaiseExceptionEvent; end

  end
end
