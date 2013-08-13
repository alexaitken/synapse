module Synapse
  module Router
    class MessageHandler
      include Comparable

      # @return [Class]
      attr_reader :subject_type

      # @return [Class]
      attr_reader :payload_type

      # @return [Hash]
      attr_reader :options

      # @return [MessageHandlerScore]
      attr_reader :score

      # @param [Class] subject_type
      # @param [Class] payload_type
      # @param [Object] handler
      # @param [Hash] options
      # @return [undefined]
      def initialize(subject_type, payload_type, handler, options)
        @subject_type = subject_type
        @payload_type = payload_type
        @handler = handler
        @options = options

        @score = MessageHandlerScore.new subject_type, payload_type
      end

      # @param [Message] message
      # @return [Boolean]
      def matches?(message)
        @payload_type >= message.payload_type
      end

      # @param [Object] target
      # @param [Message] message
      # @return [Object] The result of the invocation
      def invoke(target, message)
        # OPTIMIZE Could memoize the entire invocation into a lambda
        if @handler.is_a? Symbol
          method = target.method @handler
          args = resolve method.parameters, message

          if method.arity > args.size || method.arity == 0
            raise ArgumentError, 'Method signature is invalid'
          end

          method.call(*args.slice(0, method.arity))
        else
          args = resolve @handler.parameters, message
          target.instance_exec(*args, &@handler)
        end
      end

      # @param [MessageHandlerScore] other
      # @return [Integer]
      def <=>(other)
        @score <=> other.score
      end

      # @param [MessageHandlerScore] other
      # @return [Boolean]
      def ==(other)
        other.instance_of?(self.class) && other.score == @score
      end

      alias_method :eql?, :==

      # @return [Integer]
      def hash
        @score.hash
      end

      private

      def resolve(parameters, message)
        auto_resolve = @options.fetch :auto_resolve, true

        if auto_resolve
          # TODO memoize the resulting parameter resolvers
          resolvers = Router.resolver_factory.resolvers_for parameters
          resolvers.map { |resolver|
            resolver.resolve message
          }
        else
          [message.payload, message]
        end
      end
    end # MessageHandler
  end # Router
end
