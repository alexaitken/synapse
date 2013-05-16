module Synapse
  module Wiring
    # Base mixin that make it easier to wire handlers to their respective types
    #
    # It is recommended to use mixins more specific to the component being implemented, like
    # wiring command handlers, event listeners, event-sourced members, or processes.
    #
    # @abstract
    module MessageWiring
      extend ActiveSupport::Concern

      included do
        # @return [WireRegistry]
        class_attribute :wire_registry

        # By default, the wire registry allows duplicates
        self.wire_registry = Wiring::WireRegistry.new true
      end

      module ClassMethods
        # Wires a message handler to messages with payload of the given type
        #
        # @example
        #   wire CashWithdrawnEvent do |event|
        #     # do something with the event
        #   end
        #
        # @example
        #   wire CashWithdrawnEvent :to => :on_withdraw
        #
        #   def on_withdraw(event)
        #     # do something with the event
        #   end
        #
        # Certain components that use message handling have different options that can be set
        # on wires, like wiring processes.
        #
        # @example
        #   wire SellTransactionStartedEvent, :start => true, :correlate => :transaction_id do
        #     # do something with the event
        #   end
        #
        # @api public
        # @param [Class] type
        # @param [Object...] args
        # @param [Proc] block
        # @return [undefined]
        def wire(type, *args, &block)
          options = args.extract_options!

          to = options.delete :to
          unless to
            unless block
              raise ArgumentError, 'Expected block or option :to'
            end

            to = block
          end

          wire = Wire.new type, options, to

          self.wire_registry.register wire
        end
      end

    protected

      # @param [Message] message
      # @param [Wire] wire
      # @return [Object] Result of the handler invocation
      def invoke_wire(message, wire)
        wire.invoke self, message.payload
      end
    end
  end
end
