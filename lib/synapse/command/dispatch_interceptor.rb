module Synapse
  module Command
    # Interceptor wrapping a command dispatch that can add custom behavior before or after a
    # command is dispatched to a command handler
    class DispatchInterceptor
      include AbstractType

      # @param [CommandMessage] command
      # @param [Unit] unit
      # @param [InterceptorChain] chain
      # @return [Object] The result of the execution of the command
      abstract_method :intercept
    end # DispatchInterceptor
  end # Command
end
