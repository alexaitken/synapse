module Synapse
  module Configuration
    # Represents a definition for a service being provided by the container
    # @see DefinitionBuilder
    class Definition
      # @return [Set<Symbol>] Symbols that this definition is tagged with
      attr_reader :tags

      # @param [Set] tags
      # @param [Boolean] prototype
      # @param [Proc] factory
      # @param [Object] instance
      # @return [undefined]
      def initialize(tags, prototype, factory, instance)
        @tags = tags
        @prototype = prototype
        @factory = factory
        @instance = instance
      end

      # @return [Object]
      def resolve
        if @prototype
          @factory.call
        else
          @instance ||= @factory.call
        end
      end
    end # Definition
  end # Configuration
end
