module Synapse
  module Command
    # Represents a mechanism for controlling the flow through a chain of interceptors that
    # eventually ends in the invocation of the command handler
    #
    # Interceptors can either continue the dispatch of a command by calling {#proceed} or choose
    # to block the dispatch by not calling {#proceed} at all. Interceptors can also replace the
    # command message that will be passed on in the chain.
    class InterceptorChain
      # @param [UnitOfWork] unit The current unit of work for this command dispatch
      # @param [Array] interceptors
      # @param [CommandHandler] handler
      # @return [undefined]
      def initialize(unit, interceptors, handler)
        @unit = unit
        @interceptors = interceptors.each
        @handler = handler
      end

      # @param [CommandMessage] command The command to proceed with
      # @return [Object] The result of the execution of the command
      def proceed(command)
        begin
          @interceptors.next.handle command, @unit, self
        rescue StopIteration
          @handler.handle command, @unit
        end
      end
    end
  end
end
