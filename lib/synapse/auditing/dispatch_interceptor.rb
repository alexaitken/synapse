module Synapse
  module Auditing
    class AuditingDispatchInterceptor < Command::DispatchInterceptor
      # @return [Array<AuditDataProvider>]
      attr_accessor :data_providers

      # @return [Array<AuditLogger>]
      attr_accessor :loggers

      def initialize
        @data_providers = Array.new
        @loggers = Array.new
      end

      # @param [CommandMessage] command
      # @param [UnitOfWork] unit The current unit of work for this command dispatch
      # @param [InterceptorChain] chain
      # @return [Object] The result of the execution of the command
      def intercept(command, unit, chain)
        audit_listener = AuditingUnitOfWorkListener.new command, @data_providers, @loggers
        unit.register_listener audit_listener

        chain.proceed(command).tap do |result|
          audit_listener.return_value = result
        end
      end
    end
  end
end
