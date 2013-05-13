module Synapse
  module ProcessManager
    # Represents a mechanism for create instances of processes
    # @abstract
    class ProcessFactory
      # Creates a new instance of a process of a given type
      #
      # The returned process will be fully initialized and any resources required will be
      # provided through dependency injection.
      #
      # @abstract
      # @param [Class] process_type
      # @return [Process]
      def create(process_type); end

      # Returns true if processes of the given type can be created by this factory
      #
      # @abstract
      # @param [Class] process_type
      # @return [Boolean]
      def supports(process_type); end
    end

    # Generic implementation of a process factory that supports any process implementations that
    # have a no-argument constructor
    class GenericProcessFactory < ProcessFactory
      # @return [ResourceInjector]
      attr_accessor :resource_injector

      # @return [undefined]
      def initialize
        @resource_injector = ResourceInjector.new
      end

      # @param [Class] process_type
      # @return [Process]
      def create(process_type)
        process = process_type.new
        process.tap do
          @resource_injector.inject_resources process
        end
      end

      # @param [Class] process_type
      # @return [Boolean]
      def supports(process_type)
        ctor = process_type.instance_method :initialize
        ctor.arity <= 0
      end
    end
  end
end
