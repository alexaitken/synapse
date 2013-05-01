module Synapse
  module EventSourcing
    # Base mixin for a member of an aggregate which has its state mutated by events that are
    # applied to the aggregate
    module Member
      extend ActiveSupport::Concern

      module ClassMethods
        # Registers an instance variable as a child entity
        #
        # @param [Symbol...] fields
        # @return [undefined]
        def child_entity(*fields)
          fields.each do |field|
            child_entities.add field.to_s
          end
        end

        # Returns a set of symbols referring to child entities
        # @return [Set]
        def child_entities
          @child_entities ||= Set.new
        end
      end

    protected

      # Returns an array of the child entities of this aggregate member
      # @return [Array]
      def child_entities
        entities = Array.new

        self.class.child_entities.each do |field|
          value = instance_variable_get '@' + field

          if value.is_a? Entity
            entities.push value

          # Hashes
          elsif value.is_a? Hash
            entities.concat filter_entities value.each_key
            entities.concat filter_entities value.each_value

          # Sets, arrays
          elsif value.is_a? Enumerable
            entities.concat filter_entities value
          end
        end

        entities
      end

      # If the event is relative to this member, its parameters will be used to change
      # the state of this member
      #
      # @abstract
      # @param [EventMessage] event
      # @return [undefined]
      def handle_event(event); end

    private

      # @param [Array] source
      # @return [Array]
      def filter_entities(entities)
        entities.select do |entity|
          entity.is_a? Member
        end
      end
    end
  end
end
