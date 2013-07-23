module Synapse
  module Command
    # Implementation of a command bus that dispatches commands in the calling thread
    # @todo Thread safety?
    class SimpleCommandBus < CommandBus
      include Loggable

      # @return [RollbackPolicy]
      attr_accessor :rollback_policy

      # @param [UnitOfWorkFactory] unit_factory
      # @return [undefined]
      def initialize(unit_factory)
        @unit_factory = unit_factory

        # @todo This should be a thread-safe structure
        @handlers = Hash.new

        @filters = Array.new
        @interceptors = Array.new

        @rollback_policy = RollbackOnAnyExceptionPolicy.new
      end

      # @api public
      # @param [CommandMessage] command
      # @return [undefined]
      def dispatch(command)
        dispatch_with_callback command, VoidCallback.new
      end

      # @api public
      # @param [CommandMessage] command
      # @param [CommandCallback] callback
      # @return [undefined]
      def dispatch_with_callback(command, callback)
        result = perform_dispatch command
        callback.on_success result
      rescue => exception
        backtrace = exception.backtrace.join $RS
        logger.error "Exception occured while dispatching command {#{command.payload_type}} {#{command.id}}:\n" +
          "#{exception.inspect} #{backtrace}"

        callback.on_failure exception
      end

      # @api public
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [CommandHandler] The command handler being replaced, if any
      def subscribe(command_type, handler)
        current = @handlers.fetch command_type, nil

        @handlers.store command_type, handler
        logger.debug "Command handler {#{handler.class}} subscribed to command type {#{command_type}}"

        current
      end

      # @api public
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [Boolean] True if command handler was unsubscribed from command handler
      def unsubscribe(command_type, handler)
        current = @handlers.fetch command_type, nil

        if current.equal? handler
          @handlers.delete command_type
          logger.debug "Command handler {#{handler.class}} unsubscribed from command type {#{command_type}}"

          true
        else
          false
        end
      end

      # @param [Enumerable<CommandFilter>] filters
      # @return [undefined]
      def filters=(filters)
        @filters = Array.new filters
      end

      # @param [Enumerable<DispatchInterceptor>] interceptors
      # @return [undefined]
      def interceptors=(interceptors)
        @interceptors = Array.new interceptors
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
          logger.info "Dispatching command {#{command.id}} {#{command.payload_type}} to handler {#{handler.class}}"

          result = chain.proceed command
        rescue => exception
          if @rollback_policy.should_rollback exception
            logger.debug 'Unit of work is being rolled back due to rollback policy'
            unit.rollback exception
          else
            logger.info 'Unit of work is being committed due to rollback policy'
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
        command_type = command.payload_type

        begin
          @handlers.fetch command_type
        rescue KeyError
          raise NoHandlerError, "No handler subscribed for command {#{command_type}}"
        end
      end
    end # SimpleCommandBus
  end # Command
end
