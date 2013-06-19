module Synapse
  module Command
    # Implementation of a command bus that dispatches commands in the calling thread
    # @todo Thread safety?
    class SimpleCommandBus < CommandBus
      # @return [RollbackPolicy]
      attr_accessor :rollback_policy

      # @return [Array<CommandFilter>]
      attr_reader :filters

      # @return [Array<DispatchInterceptor>]
      attr_reader :interceptors

      # @param [UnitOfWorkFactory] unit_factory
      # @return [undefined]
      def initialize(unit_factory)
        @unit_factory = unit_factory

        @handlers = Hash.new
        @filters = Array.new
        @interceptors = Array.new

        @rollback_policy = RollbackOnAnyExceptionPolicy.new

        @logger = Logging.logger[self.class]
      end

      # @api public
      # @param [CommandMessage] command
      # @return [undefined]
      def dispatch(command)
        dispatch_with_callback command, CommandCallback.new
      end

      # @api public
      # @param [CommandMessage] command
      # @param [CommandCallback] callback
      # @return [undefined]
      def dispatch_with_callback(command, callback)
        begin
          result = perform_dispatch command
          callback.on_success result
        rescue => exception
          backtrace = exception.backtrace.join $/
          @logger.error 'Exception occured while dispatching command [%s] [%s]: %s %s' %
            [command.payload_type, command.id, exception.inspect, backtrace]

          callback.on_failure exception
        end
      end

      # @api public
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [undefined]
      def subscribe(command_type, handler)
        if @handlers.has_key? command_type
          current_handler = @handlers.fetch command_type
          @logger.info 'Command handler [%s] is being replaced by [%s] for command type [%s]' %
            [current_handler.class, handler.class, command_type]
        else
          @logger.debug 'Command handler [%s] subscribed to command type [%s]' %
            [handler.class, command_type]
        end

        @handlers.store command_type, handler
      end

      # @api public
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [undefined]
      def unsubscribe(command_type, handler)
        if @handlers.has_key? command_type
          current_handler = @handlers.fetch command_type
          if current_handler.equal? handler
            @handlers.delete command_type

            @logger.debug 'Command handler [%s] unsubscribed from command type [%s]' %
              [handler.class, command_type]
          else
            @logger.info 'Command type [%s] subscribed to handler [%s] not [%s]' %
              [command_type, current_handler.class, handler.class]
          end
        else
          @logger.info 'Command type [%s] not subscribed to any handler' % command_type
        end
      end

    protected

      # @raise [CommandExecutionError]
      #   If an error occurs during the handling of the command
      # @raise [NoHandlerError]
      #   If no handler is subscribed that is capable of handling the command
      # @param [CommandMessage] command
      # @return [Object] The result from the command handler
      def perform_dispatch(command)
        @filters.each do |filter|
          command = filter.filter command
        end

        handler = handler_for command
        unit = @unit_factory.create

        chain = InterceptorChain.new unit, @interceptors, handler

        begin
          @logger.info 'Dispatching command [%s] [%s] to handler [%s]' %
            [command.id, command.payload_type, handler.class]

          result = chain.proceed command
        rescue => exception
          if @rollback_policy.should_rollback exception
            @logger.debug 'Unit of work is being rolled back due to rollback policy'
            unit.rollback exception
          else
            @logger.info 'Unit of work is being committed due to rollback policy'
            unit.commit
          end

          raise CommandExecutionError, exception
        end

        unit.commit

        result
      end

      # @raise [NoHandlerError]
      # @param [CommandMessage] command
      # @return [CommandHandler]
      def handler_for(command)
        type = command.payload_type

        begin
          @handlers.fetch type
        rescue KeyError
          raise NoHandlerError, 'No handler subscribed for command [%s]' % type
        end
      end
    end # SimpleCommandBus
  end # Command
end
