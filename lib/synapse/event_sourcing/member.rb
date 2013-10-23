module Synapse
  module EventSourcing
    # Base mixin for a member of an aggregate which has its state mutated by events that are
    # applied to the aggregate
    #
    # @see AggregateRoot
    # @see Entity
    module Member
      extend ActiveSupport::Concern

      included do
        # @return [Set]
        inherit_accessor :child_fields do
          Set.new
        end

        # @return [MessageRouter]
        inherit_accessor :event_router do
          Router.create_router
        end
      end

      module ClassMethods
        # @param [Symbol...] names
        # @return [undefined]
        def member(*names)
          names.each { |n| child_fields.add n }
        end

        alias_method :members, :member

        # @see MessageRouter#route
        # @return [undefined]
        def route_event(*args, &block)
          event_router.route self, *args, &block
        end
      end

      protected

      # Returns an array of the child entities of this aggregate member
      # @return [Array]
      def child_entities
        child_fields.map { |field|
          value = instance_variable_get "@#{field}"

          if value.respond_to? :handle_aggregate_event
            value
          elsif value.respond_to? :each
            value.to_enum.select { |v|
              v.respond_to? :handle_aggregate_event
            }
          end
        }.flatten.compact
      end

      # If the event is relevant to this member, its parameters will be used to change
      # the state of this member
      #
      # @param [EventMessage] event
      # @return [undefined]
      def handle_event(event)
        handler = event_router.handler_for event
        if handler
          handler.invoke self, event
        end
      end
    end # Member
  end # EventSourcing
end
