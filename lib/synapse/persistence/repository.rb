module Synapse
  module Persistence
    # Represents a mechanism for loading and storing aggregates
    class Repository
      include AbstractType

      # @return [EventBus]
      attr_accessor :event_bus

      # Loads an aggregate with the given aggregate identifier
      #
      # If an expected version is specified and the aggregate's actual version doesn't equal the
      # expected version, the implementation can choose to do one of the following:
      #
      # - Raise an exception immediately
      # - Raise an exception at any other time while the aggregate is registered with the current
      #   unit of work.
      #
      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version If this is nil, no version validation is performed
      # @return [AggregateRoot]
      abstract_method :load

      # Adds a new, unmanaged aggregate to the repository
      #
      # This method will not force the repository to save the aggregate immediately. Instead, it is
      # registered with the current unit of work. To force storage of an aggregate, commit the
      # current unit of work.
      #
      # @raise [ArgumentError] If the aggregate has a version
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      abstract_method :add

      protected

      # Returns the type of aggregate that this repository handles
      # @return [Class]
      abstract_method :aggregate_type

      # Deletes the given aggregate from the underlying storage mechanism
      #
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      abstract_method :delete_aggregate

      # Saves the given aggregate using the underlying storage mechanism
      #
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      abstract_method :save_aggregate

      # Registers the given aggregate with the current unit of work
      #
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def register_aggregate(aggregate)
        current_unit.register_aggregate(aggregate, @event_bus) do |ar|
          if ar.deleted?
            delete_aggregate ar
          else
            save_aggregate ar
          end

          ar.mark_committed
        end
      end

      # Registers the given unit of work listener with the current unit of work
      #
      # @param [UnitListener] listener
      # @return [undefined]
      def register_unit_listener(listener)
        current_unit.register_listener listener
      end

      # Ensures that an aggregate being added is compatible with this repository and is newly
      # created
      #
      # @raise [ArgumentError] If aggregate is not of the correct type
      # @raise [ArgumentError] If aggregate has a version number
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def ensure_compatible(aggregate)
        unless aggregate.is_a? aggregate_type
          raise ArgumentError, 'Incompatible aggregate type'
        end

        if aggregate.version
          raise ArgumentError, 'Only newly created aggregates may be added'
        end
      end

      # Ensures that a loaded aggregate has the expected version
      #
      # @raise [ConflictingAggregateVersionError]
      #   If aggregate version is later than the expected version
      # @param [AggregateRoot] aggregate
      # @param [Integer] expected_version
      # @return [undefined]
      def ensure_version_expected(aggregate, expected_version)
        if expected_version && aggregate.version && aggregate.version != expected_version
          raise ConflictingAggregateVersionError
        end
      end

      # @return [Unit]
      def current_unit
        UnitOfWork.current
      end
    end # Repository
  end # Persistence
end
