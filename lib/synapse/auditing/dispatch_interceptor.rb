module Synapse
  module Auditing
    # Interceptor that applies auditing to the dispatch of a command
    class AuditingDispatchInterceptor
      include Command::DispatchInterceptor

      # @return [DataProvider]
      attr_accessor :data_provider

      # @return [AuditLogger]
      attr_accessor :logger

      # @return [undefined]
      def initialize
        @data_provider = EmptyDataProvider.new
        @logger = NullAuditLogger.new
      end

      # @param [CommandMessage] command
      # @param [UnitOfWork] unit The current unit of work for this command dispatch
      # @param [InterceptorChain] chain
      # @return [Object] The result of the execution of the command
      def intercept(command, unit, chain)
        audit_listener = AuditingUnitListener.new command, @data_provider, @logger
        unit.register_listener audit_listener

        result = chain.proceed command
        audit_listener.return_value = result

        result
      end
    end # AuditingDispatchInterceptor
  end # Auditing
end
