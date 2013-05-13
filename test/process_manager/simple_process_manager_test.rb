require 'test_helper'

module Synapse
  module ProcessManager
    class SimpleProcessManagerTest < Test::Unit::TestCase
      def setup
        @repository = Object.new
        @factory = GenericProcessFactory.new
        @resolver = MetadataCorrelationResolver.new :order_id
        @lock_manager = Object.new
        @manager = SimpleProcessManager.new @repository, @factory, @lock_manager, @resolver, TestProcess
      end

      def test_notify_new_process
        @manager.optionally_create_events << CauseProcessCreationEvent

        correlation = Correlation.new :order_id, 123

        mock(@repository).find(TestProcess, correlation) do
          Array.new
        end

        mock(@repository).add(is_a(TestProcess))

        event = create_domain_event 123, CauseProcessCreationEvent.new
        @manager.notify event
      end

      def test_notify_existing_process
        correlation = Correlation.new :order_id, 123

        process = TestProcess.new
        process.correlations.add correlation

        mock(@repository).find(TestProcess, correlation) do
          [process]
        end
        mock(@lock_manager).obtain_lock(process).ordered
        mock(@repository).commit(process).ordered
        mock(@lock_manager).release_lock(process).ordered

        event = create_domain_event 123, CauseProcessNotificationEvent.new
        @manager.notify event

        assert_equal 1, process.handled
      end

      def test_notify_process_raises_but_suppressed
        correlation = Correlation.new :order_id, 123

        process = TestProcess.new
        process.correlations.add correlation

        mock(@repository).find(TestProcess, correlation) do
          [process]
        end
        mock(@lock_manager).obtain_lock(process).ordered
        mock(@repository).commit(process).ordered
        mock(@lock_manager).release_lock(process).ordered

        event = create_domain_event 123, CauseProcessRaiseExceptionEvent.new
        @manager.notify event

        assert_nil process.handled
      end

      def test_notify_process_raises
        correlation = Correlation.new :order_id, 123

        process = TestProcess.new
        process.correlations.add correlation

        mock(@repository).find(TestProcess, correlation) do
          [process]
        end
        mock(@lock_manager).obtain_lock(process).ordered
        mock(@repository).commit(process).ordered
        mock(@lock_manager).release_lock(process).ordered

        event = create_domain_event 123, CauseProcessRaiseExceptionEvent.new

        @manager.suppress_exceptions = false

        assert_raise RuntimeError do
          @manager.notify event
        end
      end

      def test_always_create
        @manager.always_create_events << CauseProcessCreationEvent

        correlation = Correlation.new :order_id, 123

        processes = Array.new

        # Each time, the manager will check for existing processes
        mock(@repository).find(TestProcess, correlation).twice do
          processes
        end

        # Each time, the manager will add a new process to the repository
        mock(@repository).add(is_a(TestProcess)).twice do |process|
          processes << process
        end

        # On the second time, the manager will load the existing process, notify it of the
        # event, commit it, and then create a new process
        mock(@lock_manager).obtain_lock(is_a(TestProcess)).ordered
        mock(@repository).commit(is_a(TestProcess)).ordered
        mock(@lock_manager).release_lock(is_a(TestProcess)).ordered

        event = create_domain_event 123, CauseProcessCreationEvent.new
        @manager.notify event
        @manager.notify event

        assert_equal 2, processes.count
      end

    private

      def create_domain_event(order_id, event)
        Domain::DomainEventMessage.build do |builder|
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
