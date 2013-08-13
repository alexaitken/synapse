module Synapse
  module Router
    class ParameterResolverFactory
      # @return [undefined]
      def initialize
        @resolvers = Array.new
      end

      # @param [ParameterResolver] resolver
      # @return [undefined]
      def register(resolver)
        @resolvers.push resolver
      end

      # @param [Array] parameters
      # @return [Array]
      def resolvers_for(parameters)
        parameters.each_with_index.map { |spec, index|
          type, name = *spec
          resolver = @resolvers.find { |resolver|
            resolver.can_resolve? index, name
          }

          raise UnknownParameterTypeError unless resolver

          resolver
        }
      end
    end # ParameterResolverFactory
  end # Router
end
