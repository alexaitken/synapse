module Synapse
  module Command
    # Interceptor wrapping a command dispatch that can add custom behavior before or after a
    # command is dispatched to a command handler
    #
    # @abstract
    class DispatchInterceptor
      # @abstract
      # @param [CommandMessage] command
      # @param [UnitOfWork] unit The current unit of work for this command dispatch
      # @param [InterceptorChain] chain
      # @return [Object] The result of the execution of the command
      def intercept(command, unit, chain); end
    end
  end
end
