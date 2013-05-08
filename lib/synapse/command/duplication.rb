module Synapse
  module Command
    # Filter that prevents duplicate commands from reaching the command handlers
    class DuplicationFilter < CommandFilter
      # @param [DuplicationRecorder] recorder
      # @return [undefined]
      def initialize(recorder)
        @recorder = recorder
      end

      # @param [CommandMessage] command
      # @return [CommandMessage] The command to dispatch on the bus
      def filter(command)
        @recorder.record command
        command
      end
    end

    # Interceptor that removes commands from the duplication recorder if their execution results
    # in a transient error (like concurrency error) being raised. This way, the same command can
    # be retried by the client or command gateway
    class DuplicationCleanupInterceptor < DispatchInterceptor
      # @param [DuplicationRecorder] recorder
      # @return [undefined]
      def initialize(recorder)
        @recorder = recorder
      end

      # @param [CommandMessage] command
      # @param [UnitOfWork] unit The current unit of work for this command dispatch
      # @param [InterceptorChain] chain
      # @return [Object] The result of the execution of the command
      def handle(command, unit, chain)
        begin
          chain.proceed command
        rescue TransientError
          @recorder.forget command
          raise
        end
      end
    end
  end
end
