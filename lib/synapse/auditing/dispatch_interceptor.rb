module Synapse
  module Auditing
    # Interceptor that applies auditing to the dispatch of a command
    class AuditingDispatchInterceptor < Command::DispatchInterceptor
      # @param [Array] data_providers
      # @param [Array] loggers
      # @return [undefined]
      def initialize(data_providers, loggers)
        @data_providers = data_providers
        @loggers = loggers
      end

      # @param [CommandMessage] command
      # @param [UnitOfWork] unit The current unit of work for this command dispatch
      # @param [InterceptorChain] chain
      # @return [Object] The result of the execution of the command
      def intercept(command, unit, chain)
        audit_listener = AuditingUnitOfWorkListener.new command, @data_providers, @loggers
        unit.register_listener audit_listener

        result = chain.proceed command
        audit_listener.return_value = result

        result
      end
    end # AuditingDispatchInterceptor
  end # Auditing
end
