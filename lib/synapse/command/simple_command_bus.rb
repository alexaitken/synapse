module Synapse
  module Command
    # Implementation of a command bus that dispatches commands in the calling thread
    #
    # @!attribute [w] filters
    #   @return [Enumerable]
    # @!attribute [w] interceptors
    #   @return [Enumerable]
    # @!attribute [w] transaction_manager
    #   @return [TransactionManager]
    class SimpleCommandBus < CommandBus
      include Loggable

      # @return [undefined]
      def initialize
        @unit_factory = UnitFactory.new

        @filters = Hamster.list
        @interceptors = Hamster.list
        @subscriptions = ThreadSafe::Cache.new

        @rollback_policy = RollbackOnAnyExceptionPolicy.new
      end

      # @param [CommandMessage] command
      # @return [undefined]
      def dispatch(command)
        perform_dispatch(filter(command), VoidCallback.new)
      end

      # @param [CommandMessage] command
      # @param [CommandCallback] callback
      # @return [undefined]
      def dispatch_with_callback(command, callback)
        perform_dispatch(filter(command), callback)
      end

      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [CommandHandler] The command handler being replaced, if any
      def subscribe(command_type, handler)
        replaced = @subscriptions.get_and_set command_type, handler

        if replaced
          logger.info "Replacing {#{replaced.class}} with {#{handler.class}} for command {#{command_type}}"
        else
          logger.debug "Subscribing {#{handler.class}} to command {#{command_type}}"
        end

        replaced
      end

      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [Boolean] True if command handler was unsubscribed from command handler
      def unsubscribe(command_type, handler)
        if @subscriptions.delete_pair command_type, handler
          logger.debug "Unsubscribing handler {#{handler.class}} from command {#{command_type}}"
          true
        else
          false
        end
      end

      # @param [Enumerable] filters
      # @return [undefined]
      def filters=(filters)
        @filters = filters.to_list
      end

      # @param [Enumerable] interceptors
      # @return [undefined]
      def interceptors=(interceptors)
        @interceptors = interceptors.to_list
      end

      # @return [RollbackPolicy]
      attr_writer :rollback_policy

      # @param [TransactionManager] transaction_manager
      # @return [undefined]
      def transaction_manager=(transaction_manager)
        @unit_factory = UnitFactory.new transaction_manager
      end

      # @return [UnitFactory]
      attr_writer :unit_factory

      protected

      # @param [CommandMessage] command
      # @param [CommandCallback] callback
      # @return [undefined]
      def perform_dispatch(command, callback)
        handler = handler_for command

        begin
          result = dispatch_to_handler command, handler
          callback.on_success result
        rescue
          callback.on_failure $!
        end
      end

      private

      # @param [CommandMessage] command
      # @return [CommandMessage]
      def filter(command)
        @filters.reduce(command) { |a, e| e.filter a }
      end

      # @param [CommandMessage] command
      # @param [CommandHandler] handler
      # @return [Object]
      def dispatch_to_handler(command, handler)
        logger.debug "Dispatching command {#{command.payload_type}} to {#{handler.class}}"

        current_unit = @unit_factory.create
        chain = InterceptorChain.new current_unit, @interceptors, handler

        begin
          result = chain.proceed command
        rescue => exception
          on_execution_error exception, current_unit
          raise
        end

        current_unit.commit
        result
      end

      # @param [Exception] exception
      # @param [UnitOfWork] current_unit
      # @return [undefined]
      def on_execution_error(exception, current_unit)
        if @rollback_policy.should_rollback? exception
          logger.debug 'Unit of work is being rolled back due to rollback policy'
          current_unit.rollback exception
        else
          logger.info 'Unit of work is being committed due to rollback policy'
          current_unit.commit
        end
      end

      # @raise [NoHandlerError]
      # @param [CommandMessage] command
      # @return [CommandHandler]
      def handler_for(command)
        command_type = command.payload_type

        begin
          @subscriptions.fetch command_type
        rescue KeyError
          raise NoHandlerError, "No handler subscribed for command {#{command_type}}"
        end
      end

      # Aliases
      UnitFactory = UnitOfWork::UnitFactory
    end # SimpleCommandBus
  end # Command
end
