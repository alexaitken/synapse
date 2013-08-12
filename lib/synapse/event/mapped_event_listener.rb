module Synapse
  module Event
    module MappedEventListener
      # @param [Module] descendant
      # @return [undefined]
      def self.included(descendant)
        descendant.instance_eval do
          extend ClassMethods

          inheritable_accessor :event_mapper do
            Mapping.create_mapper
          end
        end
      end

      module ClassMethods
        # @see MessageMapper#map
        # @param [Object...] args
        # @return [undefined]
        def map_event(*args, &block)
          event_mapper.map self, *args, &block
        end
      end

      # @param [EventMessage] event
      # @return [undefined]
      def notify(event)
        handler = event_mapper.handler_for event
        if handler
          handler.invoke self, event
        end
      end
    end # MappedEventListener
  end # Event
end
