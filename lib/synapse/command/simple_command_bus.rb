module Synapse
  module Command
    # Implementation of a command bus that dispatches commands in the calling thread
    # @todo Thread safety?
    class SimpleCommandBus < CommandBus
      # @param [UnitOfWorkFactory] unit_factory
      # @return [undefined]
      def initialize(unit_factory)
        @handlers = Hash.new
        @unit_factory = unit_factory
      end

      # @raise [CommandExecutionError]
      #   If an error occurs during the handling of the command
      # @raise [NoHandlerError]
      #   If no handler is subscribed that is capable of handling the command
      # @param [CommandMessage] command
      # @return [undefined]
      def dispatch(command)
        unit = @unit_factory.create

        begin
          handler = handler_for command
          handler.handle command, unit
        rescue => exception
          logger.error 'Exception occured while dispatching command [%s] [%s]; rolling back' %
            [command.payload_type, command.id]

          unit.rollback exception
          raise CommandExecutionError, exception
        end

        unit.commit
      end

      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [undefined]
      def subscribe(command_type, handler)
        if @handlers.has_key? command_type
          current_handler = @handlers.fetch command_type
          logger.info 'Command handler [%s] is being replaced by [%s] for command type [%s]' %
            [current_handler.class, handler.class, command_type]
        else
          logger.debug 'Command handler [%s] subscribed to command type [%s]' %
            [handler.class, command_type]
        end

        @handlers.store command_type, handler
      end

      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [undefined]
      def unsubscribe(command_type, handler)
        if @handlers.has_key? command_type
          current_handler = @handlers.fetch command_type
          if current_handler.equal? handler
            @handlers.delete command_type

            logger.debug 'Command handler [%s] unsubscribed from command type [%s]' %
              [handler.class, command_type]
          else
            logger.info 'Command type [%s] subscribed to handler [%s] not [%s]' %
              [command_type, current_handler.class, handler.class]
          end
        else
          logger.info 'Command type [%s] not subscribed to any handler' % command_type
        end
      end

    private

      # @raise [NoHandlerError]
      # @param [CommandMessage]
      # @return [CommandHandler]
      def handler_for(command)
        type = command.payload_type

        begin
          @handlers.fetch type
        rescue KeyError
          raise NoHandlerError, 'No handler subscribed for command [%s]' % type
        end
      end

      # @return [Logger]
      def logger
        @logger ||= Logging.logger[self.class]
      end
    end
  end
end