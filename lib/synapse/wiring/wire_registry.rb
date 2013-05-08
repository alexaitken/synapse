module Synapse
  module Wiring
    class WireRegistry
      # @param [Boolean] duplicates_allowed
      # @return [undefined]
      def initialize(duplicates_allowed)
        @duplicates_allowed = duplicates_allowed
        @wires = Array.new
      end

      # Yields the type that each wire is registered for
      #
      # @yield [Class]
      # @return [undefined]
      def each_type
        @wires.each do |wire|
          yield wire.type
        end
      end

      # @raise [DuplicateWireError] If duplicates aren't allowed and another wire exists that
      #   wires the exact same type as the given wire
      # @param [Wire] wire
      # @return [undefined]
      def register(wire)
        unless @duplicates_allowed
          if @wires.include? wire
            raise DuplicateWireError
          end
        end

        @wires.push wire
        @wires.sort!
      end

      # Retrieves the most specific wire for a given type, if any
      #
      # @param [Class] target_type
      # @return [Wire]
      def wire_for(target_type)
        @wires.find do |wire|
          wire.type >= target_type
        end
      end

      # Retrieves any wires for a given type, regardless of specificity
      #
      # @param [Class] target_type
      # @return [Array]
      def wires_for(target_type)
        @wires.find_all do |wire|
          wire.type >= target_type
        end
      end
    end

    # Raised if a wire registry doesn't allow duplicates and an attempt is made to wire the same
    # type to multiple handlers
    class DuplicateWireError < NonTransientError; end
  end
end
