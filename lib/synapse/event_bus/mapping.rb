module Synapse
  module EventBus
    # Mixin for an event listener that wishes to use the mapping DSL
    #
    # @example
    #   class OrderBookManagementListener
    #     include MappingEventListener
    #
    #     map_event UserRegistered do |event|
    #       # ...
    #     end
    #
    #     map_event UserBanned, :to => :on_banned
    #   end
    module MappingEventListener
      extend ActiveSupport::Concern
      include EventListener

      included do
        # @return [Mapping::Mapper]
        class_attribute :event_mapper
        self.event_mapper = Mapping::Mapper.new true
      end

      module ClassMethods
        def map_event(type, *args, &block)
          event_mapper.map type, *args, &block
        end
      end

      # @param [EventMessage] event
      # @return [undefined]
      def notify(event)
        mapping = event_mapper.mapping_for event.payload_type

        return unless mapping

        mapping.invoke self, event.payload
      end
    end # MappingEventListener
  end # EventBus
end
