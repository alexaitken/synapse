require 'test_helper'

module Synapse
  module ProcessManager
    class SimpleProcessManagerTest < Test::Unit::TestCase
      def setup
        @repository = InMemoryProcessRepository.new
        @factory = GenericProcessFactory.new
        @resolver = MetadataCorrelationResolver.new :order_id
        @lock_manager = Object.new
        @manager = SimpleProcessManager.new @repository, @factory, @lock_manager, @resolver, TestProcess
      end

      should 'create a new process and notify it if one could not be found' do
        @manager.optionally_create_events << CauseProcessCreationEvent

        correlation = Correlation.new :order_id, 123

        mock(@lock_manager).obtain_lock(is_a(String))
        mock(@lock_manager).release_lock(is_a(String))

        @manager.notify create_event 123, CauseProcessCreationEvent.new

        assert_equal 1, @repository.count
      end

      should 'load and notify an existing process correlated with an event' do
        process = TestProcess.new
        process.correlations.add Correlation.new :order_id, 123

        @repository.add process

        mock(@lock_manager).obtain_lock(process.id)
        mock(@lock_manager).release_lock(process.id)

        @manager.notify create_event 123, CauseProcessNotificationEvent.new

        assert_equal 1, @repository.count
      end

      should 'suppress exceptions raised by a process while handling an event' do
        process = TestProcess.new
        process.correlations.add Correlation.new :order_id, 123

        @repository.add process

        mock(@lock_manager).obtain_lock(process.id)
        mock(@lock_manager).release_lock(process.id)

        @manager.notify create_event 123, CauseProcessRaiseExceptionEvent.new

        assert_equal 1, @repository.count
      end

      should 'release its lock before raising an exception caused by a process' do
        process = TestProcess.new
        process.correlations.add Correlation.new :order_id, 123

        @repository.add process

        mock(@lock_manager).obtain_lock(process.id)
        mock(@lock_manager).release_lock(process.id)

        @manager.suppress_exceptions = false

        assert_raise RuntimeError do
          @manager.notify create_event 123, CauseProcessRaiseExceptionEvent.new
        end
      end

      should 'always create a process if specified by the creation policy' do
        @manager.always_create_events << CauseProcessCreationEvent

        correlation = Correlation.new :order_id, 123

        # Lock is obtain/released for the 2 being created and once for the first being changed
        mock(@lock_manager).obtain_lock(is_a(String)).times(3)
        mock(@lock_manager).release_lock(is_a(String)).times(3)

        @manager.notify create_event 123, CauseProcessCreationEvent.new
        @manager.notify create_event 123, CauseProcessCreationEvent.new

        assert_equal 2, @repository.count
      end

    private

      def create_event(order_id, event)
        Domain::EventMessage.build do |builder|
          builder.payload = event
          builder.metadata = {
            order_id: order_id
          }
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

    # Test process that has all sorts of trigger events
    class TestProcess < Process
      attr_accessor :handled

      def handle(event)
        if event.payload_type == CauseProcessRaiseExceptionEvent
          raise 'ohgodimnotgoodwithcomputers'
        end

        @handled ||= 0
        @handled = @handled.next
      end
    end

    class CauseProcessCreationEvent; end
    class CauseProcessNotificationEvent; end
    class CauseProcessRaiseExceptionEvent; end
  end
end
