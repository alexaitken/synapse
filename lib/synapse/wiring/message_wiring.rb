module Synapse
  module Wiring
    # Base mixin that make it easier to wire handlers to their respective types
    # @abstract
    module MessageWiring
      extend ActiveSupport::Concern

      included do
        # @return [WireRegistry]
        class_attribute :wire_registry
      end

      module ClassMethods
        def wire(type, *args, &block)
          options = args.extract_options!

          unless options[:to]
            unless block
              raise ArgumentError, 'Expected block or option :to'
            end

            options[:to] = block
          end

          wire = Wire.new type, options[:to]

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
