module Synapse
  module Router
    class MessageRouter
      # @param [Boolean] duplicates_allowed
      # @return [undefined]
      def initialize(duplicates_allowed = true)
        @handlers = Array.new
        @duplicates_allowed = duplicates_allowed
        @auto_resolve = true
      end

      # @param [MessageRouter] original
      # @return [undefined]
      def initialize_copy(original)
        super
        @handlers = @handlers.clone
      end

      # @return [undefined]
      def disable_auto_resolve
        @auto_resolve = false
      end

      # @return [undefined]
      def enable_auto_resolve
        @auto_resolve = true
      end

      # @param [Class] subject_type
      # @param [Class] payload_type
      # @param [Object...] args
      # @return [undefined]
      def route(subject_type, payload_type, *args, &block)
        options = args.extract_options!
        handler = create_from subject_type, payload_type, options, &block

        unless @duplicates_allowed
          if @handlers.include? handler
            # TODO Make error more descriptive
            raise DuplicateHandlerError
          end
        end

        @handlers.push handler
        @handlers.sort!
      end

      # @param [Message] message
      # @return [MessageHandler]
      def handler_for(message)
        @handlers.find { |handler|
          handler.matches? message
        }
      end

      private

      # @param [Class] subject_type
      # @param [Class] payload_type
      # @param [Hash] options
      # @return [MessageHandler]
      def create_from(subject_type, payload_type, options, &block)
        to = options.delete :to

        if to
          if block
            raise ArgumentError, 'Both a block and handler were given'
          end
        elsif block
          to = block
        else
          raise ArgumentError, 'Neither a block nor handler were given'
        end

        options = {
          auto_resolve: @auto_resolve
        }.merge options

        MessageHandler.new subject_type, payload_type, to, options
      end
    end # MessageRouter
  end # Router
end
