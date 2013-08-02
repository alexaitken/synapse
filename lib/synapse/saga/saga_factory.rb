module Synapse
  module Saga
    # Represents a mechanism for create instances of sagas
    # @abstract
    class SagaFactory
      # Creates a new instance of a saga of a given type
      #
      # The returned saga will be fully initialized and any resources required will be
      # provided through dependency injection.
      #
      # @abstract
      # @param [Class] saga_type
      # @return [Saga]
      def create(saga_type)
        raise NotImplementedError
      end

      # Returns true if sagas of the given type can be created by this factory
      #
      # @abstract
      # @param [Class] saga_type
      # @return [Boolean]
      def supports(saga_type)
        raise NotImplementedError
      end
    end # SagaFactory

    # Generic implementation of a saga factory that supports any saga implementations that
    # have a no-argument constructor
    class GenericSagaFactory < SagaFactory
      # @return [ResourceInjector]
      attr_accessor :resource_injector

      # @return [undefined]
      def initialize
        @resource_injector = NullResourceInjector.new
      end

      # @param [Class] saga_type
      # @return [Saga]
      def create(saga_type)
        saga = saga_type.new
        saga.tap do
          @resource_injector.inject_resources saga
        end
      end

      # @param [Class] saga_type
      # @return [Boolean]
      def supports(saga_type)
        ctor = saga_type.instance_method :initialize
        ctor.arity <= 0
      end
    end # GenericSagaFactory
  end # Saga
end
