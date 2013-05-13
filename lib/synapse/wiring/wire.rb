module Synapse
  module Wiring
    # Represents a mapping between a payload type and a handler method or block
    #
    # Wires are ordered by the depth of the payload type that they handle. Wires that are
    # for a more specific class are preferred over wires for an abstract class.
    class Wire
      # @return [Class] The type of payload that a handler is being wired to
      attr_reader :type

      # @return [Object] Either a method symbol or block
      attr_reader :handler

      # @return [Hash] Options specific to the component being wired
      attr_reader :options

      # @param [Class] type
      # @param [Hash] options
      # @param [Object] handler Either a method symbol or block
      # @return [undefined]
      def initialize(type, options, handler)
        @type = type
        @options = options
        @handler = handler
      end

      # @param [Object] target
      # @param [Object...] args
      # @return [Object] The result of the handler invocation
      def invoke(target, *args)
        if @handler.is_a? Symbol
          target.send(@handler, *args)
        else
          target.instance_exec(*args, &@handler)
        end
      end

      # @param [Wire] other
      # @return [Integer]
      def <=>(other)
        (@type <=> other.type) or 0
      end

      # @param [Wire] other
      # @return [Boolean]
      def ==(other)
        self.class === other and
          @type == other.type
      end

      alias eql? ==

      # TODO Is this a good hash function? Probs not
      # @return [Integer]
      def hash
        @type.hash
      end
    end
  end
end
