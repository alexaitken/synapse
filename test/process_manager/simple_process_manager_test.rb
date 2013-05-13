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

        mock(@lock_manager).obtain_lock(is_a(String))
        mock(@repository).add(is_a(TestProcess))
        mock(@lock_manager).release_lock(is_a(String))

        event = create_domain_event 123, CauseProcessCreationEvent.new
        @manager.notify event
      end

      def test_notify_existing_process
        correlation = Correlation.new :order_id, 123

        process = TestProcess.new
        process.correlations.add correlation

        mock(@repository).find(TestProcess, correlation) do
          [process.id]
        end
        mock(@repository).load(process.id) do
          process
        end
        mock(@lock_manager).obtain_lock(process.id)
        mock(@repository).commit(process)
        mock(@lock_manager).release_lock(process.id)

        event = create_domain_event 123, CauseProcessNotificationEvent.new
        @manager.notify event

        assert_equal 1, process.handled
      end

      def test_notify_process_raises_but_suppressed
        correlation = Correlation.new :order_id, 123

        process = TestProcess.new
        process.correlations.add correlation

        mock(@repository).find(TestProcess, correlation) do
          [process.id]
        end
        mock(@repository).load(process.id) do
          process
        end
        mock(@lock_manager).obtain_lock(process.id)
        mock(@repository).commit(process)
        mock(@lock_manager).release_lock(process.id)

        event = create_domain_event 123, CauseProcessRaiseExceptionEvent.new
        @manager.notify event

        assert_nil process.handled
      end

      def test_notify_process_raises
        correlation = Correlation.new :order_id, 123

        process = TestProcess.new
        process.correlations.add correlation

        mock(@repository).find(TestProcess, correlation) do
          [process.id]
        end
        mock(@repository).load(process.id) do
          process
        end
        mock(@lock_manager).obtain_lock(process.id)
        mock(@repository).commit(process)
        mock(@lock_manager).release_lock(process.id)

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
          processes.map do |process|
            process.id
          end
        end

        mock(@repository).load(is_a(String)) do |process_id|
          processes.find do |process|
            process.id == process_id
          end
        end

        # Each time, the manager will add a new process to the repository
        mock(@repository).add(is_a(TestProcess)).twice do |process|
          processes << process
        end

        # On the second time, the manager will load the existing process, notify it of the
        # event, commit it, and then create a new process
        mock(@repository).commit(is_a(TestProcess))

        # Lock is obtain/released for the 2 being created and once for the first being changed
        mock(@lock_manager).obtain_lock(is_a(String)).times(3)
        mock(@lock_manager).release_lock(is_a(String)).times(3)

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
