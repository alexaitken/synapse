module Synapse
  module Repository
    # Represents a mechanism for loading and storing aggregates
    # @abstract
    class Repository
      # @return [EventBus]
      attr_writer :event_bus

      # @return [UnitOfWorkProvider]
      attr_writer :unit_provider

      # Loads an aggregate with the given aggregate identifier
      #
      # If an expected version is specified and the aggregate's actual version doesn't equal the
      # expected version, the implementation can choose to do one of the following:
      #
      # - Raise an exception immediately
      # - Raise an exception at any other time while the aggregate is registered with the current
      #   unit of work.
      #
      # @abstract
      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version If this is nil, no version validation is performed
      # @return [AggregateRoot]
      def load(aggregate_id, expected_version = nil); end

      # Adds a new, unmanaged aggregate to the repository
      #
      # This method will not force the repository to save the aggregate immediately. Instead, it is
      # registered with the current unit of work. To force storage of an aggregate, commit the
      # current unit of work.
      #
      # @abstract
      # @raise [ArgumentError] If the version of the aggregate is not null
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def add(aggregate); end

    protected

      # Returns the type of aggregate that this repository handles
      #
      # @abstract
      # @return [Class]
      def aggregate_type; end

      # Returns the listener that handles aggregate storage
      #
      # @abstract
      # @return [StorageListener]
      def storage_listener; end

      # Asserts that an aggregate being added is compatible with this repository and is newly
      # created
      #
      # @raise [ArgumentError] If aggregate is not of the correct type
      # @raise [ArgumentError] If aggregate has a version number
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def assert_compatible(aggregate)
        unless aggregate.is_a? aggregate_type
          raise ArgumentError, 'Incompatible aggregate type'
        end

        if aggregate.version
          raise ArgumentError, 'Only newly created aggregates may be added'
        end
      end

      # Asserts that a loaded aggregate has the expected version
      #
      # @raise [ConflictingAggregateVersionError]
      #   If aggregate version is later than the expected version
      # @param [AggregateRoot] aggregate
      # @param [Integer] expected_version
      # @return [undefined]
      def assert_version_expected(aggregate, expected_version)
        if expected_version and aggregate.version and aggregate.version > expected_version
          raise ConflictingAggregateVersionError.new aggregate, expected_version
        end
      end

      # Registers the given aggregate with the current unit of work
      #
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def register_aggregate(aggregate)
        current_unit.register_aggregate aggregate, @event_bus, storage_listener
      end

      # Registers the given unit of work listener with the current unit of work
      #
      # @param [UnitOfWorkListener] listener
      # @return [undefined]
      def register_listener(listener)
        current_unit.register_listener listener
      end

      # @return [UnitOfWork]
      def current_unit
        @unit_provider.current
      end
    end
  end
end
