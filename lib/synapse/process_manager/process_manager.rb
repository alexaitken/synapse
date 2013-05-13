module Synapse
  module ProcessManager
    # Represents a mechanism for managing the lifeycle and notification of process instances
    # @abstract
    class ProcessManager
      include EventBus::EventListener

      # @return [Boolean] Returns true if exceptions will be logged silently
      attr_accessor :suppress_exceptions

      # @param [ProcessRepository] repository
      # @param [ProcessFactory] factory
      # @param [LockManager] lock_manager
      # @param [Class...] process_types
      # @return [undefined]
      def initialize(repository, factory, lock_manager, *process_types)
        @repository = repository
        @factory = factory
        @lock_manager = lock_manager
        @process_types = process_types.flatten

        @logger = Logging.logger[self.class]
        @suppress_exceptions = true
      end

      # @param [EventMessage] event
      # @return [undefined]
      def notify(event)
        @process_types.each do |process_type|
          correlation = extract_correlation process_type, event
          if correlation
            current = notify_current_processes process_type, event, correlation
            if should_start_new_process process_type, event, current
              start_new_process process_type, event, correlation
            end
          end
        end
      end

    protected

      # @abstract
      # @param [Class] process_type
      # @param [EventMessage] event
      # @return [Symbol]
      def creation_policy_for(process_type, event); end

      # @abstract
      # @param [Class] process_type
      # @param [EventMessage] event
      # @return [Correlation] Returns nil if no correlation could be extracted
      def extract_correlation(process_type, event); end

      # Determines whether or not a new process should be started, based off of existing processes
      # and the creation policy for the event and process
      #
      # @param [Class] process_type
      # @param [EventMessage] event
      # @param [Boolean] current_processes True if there are existing processes
      # @return [Boolean]
      def should_start_new_process(process_type, event, current_processes)
        creation_policy = creation_policy_for process_type, event

        if :always == creation_policy
          true
        elsif :if_none_found == creation_policy
          !current_processes
        else
          false
        end
      end

      # Notifies existing processes of the given type and correlation of the given event
      #
      # @param [Class] process_type
      # @param [EventMessage] event
      # @param [Correlation] correlation
      # @return [Boolean] Returns true if any current processes were found and notified
      def notify_current_processes(process_type, event, correlation)
        processes = @repository.find process_type, correlation

        if processes.empty?
          false
        else
          processes.each do |process|
            notify_current_process process, event
          end

          true
        end
      end

      # Notifies the given process of the given event, managing the locks for the process
      #
      # @param [Process] process
      # @param [EventMessage] event
      def notify_current_process(process, event)
        @lock_manager.obtain_lock process

        begin
          notify_process process, event
        ensure
          begin
            @repository.commit process
          ensure
            @lock_manager.release_lock process
          end
        end
      end

      # Creates a new process of the given type with the given correlation
      #
      # After the process has been created, it is notified of the given event and then is
      # committed to the process repository.
      #
      # @param [Class] process_type
      # @param [EventMessage] event
      # @param [Correlation] correlation
      # @return [undefined]
      def start_new_process(process_type, event, correlation)
        process = @factory.create process_type
        process.correlations.add correlation

        notify_process process, event

        @repository.add process
      end

      # Notifies the given process with of the given event
      #
      # @raise [Exception] If an error occurs while notifying the process and exception
      #   suppression is disabled
      # @param [Process] process
      # @param [EventMessage] event
      # @return [undefined]
      def notify_process(process, event)
        begin
          process.handle event
        rescue => exception
          if @suppress_exceptions
            backtrace = exception.backtrace.join $/
            @logger.error 'Exception occured while invoking process [%s] [%s] with [%s]: %s %s' %
              [process.class, process.id, event.payload_type, exception.inspect, backtrace]
          else
            raise
          end
        end
      end
    end # ProcessManager
  end # ProcessManager
end
