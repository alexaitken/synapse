module Synapse
  module Saga
    # Container that tracks additions and deletions of correlations for a saga instance
    class CorrelationSet
      extend Forwardable
      include Enumerable

      # @return [Set]
      attr_reader :correlations

      # @return [Set]
      attr_reader :additions

      # @return [Set]
      attr_reader :deletions

      def initialize
        @correlations = Set.new
        @additions = Set.new
        @deletions = Set.new
      end

      # Resets the tracked changes
      # @return [undefined]
      def commit
        @additions.clear
        @deletions.clear
      end

      # Adds the given correlation to this set, if not previously added
      #
      # @param [Correlation] correlation
      # @return [Boolean]
      def add(correlation)
        if @correlations.add? correlation
          unless @deletions.delete? correlation
            @additions.add correlation
          end
        end
      end

      # Removes the given correlation from this set, if previously added
      #
      # @param [Correlation] correlation
      # @return [Boolean]
      def delete(correlation)
        if @correlations.delete? correlation
          unless @additions.delete? correlation
            @deletions.add correlation
          end
        end
      end

      # Delegates enumeration to the backing correlation set
      def_delegators :@correlations, :each, :size
    end
  end
end
