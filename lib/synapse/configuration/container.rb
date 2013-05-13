module Synapse
  module Configuration
    # Dependency injection container
    #
    # @see [ContainerBuilder]
    # @see [ServiceDefinition]
    class Container
      # @return [undefined]
      def initialize
        @definitions = Hash.new
        @tags = Hash.new do |hash, key|
          hash[key] = Array.new
        end
      end

      # @raise [ArgumentError] If service with given id is not registered
      # @param [Symbol] id
      # @param [Boolean] optional True if service is optional
      # @return [Object]
      def fetch(id, optional = false)
        if @definitions.has_key? id
          @definitions[id].resolve self
        elsif not optional
          raise ArgumentError, 'Definition for service %s not registered' % id
        end
      end

      # @param [Symbol] tag
      # @return [Array]
      def fetch_tagged(tag)
        resolved = Array.new

        if @tags.has_key? tag
          @tags[tag].each do |identifier|
            resolved.push fetch identifier
          end
        end

        resolved
      end

      # @param [ServiceDefinition] service
      # @return [undefined]
      def register(definition)
        unless definition.id
          raise ArgumentError, 'Service definition must have an identifier'
        end

        @definitions.store definition.id, definition
      end

      # @param [Symbol] tag
      # @param [Symbol] service_id
      # @return [undefined]
      def tag_service(tag, service_id)
        @tags[tag].push service_id
      end
    end
  end
end
