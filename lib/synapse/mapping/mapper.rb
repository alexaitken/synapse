module Synapse
  module Mapping
    class Mapper
      # @param [Boolean] duplicates_allowed
      # @return [undefined]
      def initialize(duplicates_allowed)
        @duplicates_allowed = duplicates_allowed
        @mappings = Array.new
      end

      # Yields the type that each mapping is registered for
      #
      # @yield [Class]
      # @return [undefined]
      def each_type
        @mappings.each do |mapping|
          yield mapping.type
        end
      end

      # @raise [DuplicateMappingError] If duplicates aren't allowed and another mapping exists that
      #   maps the exact same type as the given mapping
      # @param [Class] type
      # @param [Object...] args
      # @param [Proc] block
      # @return [undefined]
      def map(type, *args, &block)
        options = args.extract_options!
        mapping = create_from type, options, &block

        unless @duplicates_allowed
          if @mappings.include? mapping
            raise DuplicateMappingError
          end
        end

        @mappings.push mapping
        @mappings.sort!
      end

      # Retrieves the most specific mapping for a given type, if any
      #
      # @param [Class] target_type
      # @return [Mapping]
      def mapping_for(target_type)
        @mappings.find do |mapping|
          mapping.type >= target_type
        end
      end

      # Returns the types mapped by this mapper
      # @return [Array]
      def types
        @mappings.map do |mapping|
          mapping.type
        end
      end

      private

      # @param [Class] type
      # @param [Hash] options
      # @param [Proc] block
      # @return [Mapping]
      def create_from(type, options, &block)
        to = options.delete :to
        unless to
          unless block
            raise ArgumentError, 'Expected block or option :to'
          end

          to = block
        end

        Mapping.new type, options, to
      end
    end

    # Raised if a mapping registry doesn't allow duplicates and an attempt is made to map the same
    # type to multiple handlers
    class DuplicateMappingError < NonTransientError; end
  end
end
