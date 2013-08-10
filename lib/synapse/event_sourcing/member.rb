module Synapse
  module EventSourcing
    # Base mixin for a member of an aggregate which has its state mutated by events that are
    # applied to the aggregate
    #
    # @see AggregateRoot
    # @see Entity
    module Member
      include AbstractType

      protected

      # Returns an array of the child entities of this aggregate member
      # @return [Array]
      abstract_method :child_entities

      # If the event is relative to this member, its parameters will be used to change
      # the state of this member
      #
      # @param [EventMessage] event
      # @return [undefined]
      abstract_method :handle_event
    end # Member
  end # EventSourcing
end
