module Synapse
  module Command
    # Mixin for a command handler that uses the mapping DSL
    #
    # @example
    #   class OrderBookCommandHandler
    #     include MappingCommandHandler
    #
    #     map_command CreateOrderbook do |command|
    #       # ...
    #     end
    #
    #     map_command PlaceBuyOrder, :to => :on_buy_order
    #     map_command PlaceSellOrder, :to => :on_sell_order
    #   end
    module MappingCommandHandler
      extend ActiveSupport::Concern
      include CommandHandler

      included do
        # @return [Mapping::Mapper]
        class_attribute :command_mapper
        self.command_mapper = Mapping::Mapper.new false
      end

      module ClassMethods
        # @see Mapper#map
        # @param [Class] type
        # @param [Object...] args
        # @param [Proc] block
        # @return [undefined]
        def map_command(type, *args, &block)
          command_mapper.map type, *args, &block
        end
      end

      # @param [CommandMessage] command
      # @param [UnitOfWork] current_unit Current unit of work
      # @return [Object] The result of handling the given command
      def handle(command, current_unit)
        mapping = command_mapper.mapping_for command.payload_type

        unless mapping
          raise ArgumentError, 'Not capable of handling [%s] commands' % command.payload_type
        end

        mapping.invoke self, command.payload, command, current_unit
      end

      # Subscribes this handler to the given command bus for any types that have been mapped
      #
      # @param [CommandBus] command_bus
      # @return [undefined]
      def subscribe(command_bus)
        command_mapper.each_type do |type|
          command_bus.subscribe type, self
        end
      end

      # Unsubscribes this handler from the given command bus for any types that have been mapped
      #
      # @param [CommandBus] command_bus
      # @return [undefined]
      def unsubscribe(command_bus)
        command_mapper.each_type do |type|
          command_bus.unsubscribe type, self
        end
      end
    end # MappingCommandHandler
  end # Command
end
