module Synapse
  module Configuration
    # Container used for storing and resolving definitions of services
    # @see ContainerBuilder
    class Container
      def initialize
        @definitions = Hash.new
        @logger = Logging.logger[self.class]
      end

      # Injects any configured dependencies into the given object
      #
      # @param [Dependent] object
      # @return [undefined]
      def inject_into(object)
        return unless object.is_a? Dependent

        dependencies = object.class.dependencies
        dependencies.each_pair do |id, attribute|
          # Don't replace existing attributes
          next if object.public_send attribute

          resolved = resolve id
          object.public_send "#{attribute}=", resolved
        end
      end

      # Locates the definition for a service with the given identifier and resolves it to the
      # object being provided
      #
      # @raise [ArgumentError] If definition could not be found and is required
      # @param [Symbol] id
      # @param [Boolean] optional Default is false
      # @return [Object]
      def resolve(id, optional = false)
        if @definitions.has_key? id
          @definitions[id].resolve
        elsif not optional
          raise ConfigurationError, 'Definition for service [%s] not found' % id
        end
      end

      alias [] resolve

      # Resolves any definitions that have the given tag
      #
      # @param [Symbol] tag
      # @return [Array]
      def resolve_tagged(tag)
        resolved = Array.new

        @definitions.each_value do |definition|
          if definition.tags and definition.tags.include? tag
            resolved.push definition.resolve
          end
        end

        resolved
      end

      # Registers a service definition with this container
      #
      # @param [Symbol] id
      # @param [Definition] definition
      # @return [undefined]
      def register(id, definition)
        if @definitions.has_key? id
          @logger.info 'Definition [%s] is being replaced' % id
        end

        @definitions.store id, definition
      end

      # Returns true if a service definition with the given identifier is registered
      #
      # @param [Symbol] id
      # @return [Boolean]
      def registered?(id)
        @definitions.has_key? id
      end

      # @return [String]
      def inspect
        result = "#<#{self.class}\n"
        @definitions.keys.sort.each do |key|
          definition = @definitions[key]
          result << "\t#{key} => #{definition.tags.inspect}\n"
        end
        result << ">"

        result
      end
    end # Container
  end # Configuration
end
