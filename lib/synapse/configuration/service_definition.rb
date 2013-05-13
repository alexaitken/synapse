module Synapse
  module Configuration
    # Definition for a service that is resolved by a container
    class ServiceDefinition
      # @return [Symbol]
      attr_reader :id

      # @return [Boolean]
      attr_reader :singleton

      # @return [#call]
      attr_reader :factory

      # @return [Object]
      attr_reader :instance

      alias singleton? singleton

      # @param [Symbol] id
      # @param [Boolean] singleton
      # @param [Proc] factory
      # @param [Object] instance
      # @return [undefined]
      def initialize(id, singleton, factory, instance)
        @id = id
        @singleton = singleton
        @factory = factory
        @instance = instance
      end

      # @param [Container] container
      # @return [Object]
      def resolve(container)
        if @singleton
          @instance ||= @factory.call container
        else
          @factory.call container
        end
      end
    end
  end
end
