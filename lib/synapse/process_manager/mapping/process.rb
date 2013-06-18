module Synapse
  module ProcessManager
    # Process that has the mapping DSL built-in
    #
    # @example
    #   class OrderProcess < MappingProcess
    #     map_event OrderCreatedEvent, correlate: :order_id, start: true do |event|
    #       # ...
    #     end
    #
    #     map_event OrderFinishedEvent, correlate: :order_id, finish: true, to: :on_finish
    #   end
    #
    # @abstract
    class MappingProcess < Process
      # @return [Mapping::Mapper]
      class_attribute :event_mapper

      self.event_mapper = Mapping::Mapper.new true

      # @see Mapper#map
      # @param [Class] type
      # @param [Object...] args
      # @param [Proc] block
      # @return [undefined]
      def self.map_event(type, *args, &block)
        event_mapper.map type, *args, &block
      end

      # @param [EventMessage] event
      # @return [undefined]
      def handle(event)
        return unless @active

        mapping = event_mapper.mapping_for event.payload_type
        if mapping
          mapping.invoke self, event.payload, event
          finish if mapping.options[:finish]
        end
      end
    end # MappingProcess
  end # ProcessManager
end
