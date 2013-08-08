module Synapse
  module UnitOfWork
    # Provides an entry point for accessing the current unit of work
    #
    # Components that are aware of transactional boundaries can register and clear units of work
    # for the calling thread.
    module CurrentUnit
      extend self

      # Returns true if a unit of work is active for the calling thread
      # @return [Boolean]
      def active?
        stack.size > 0
      end

      # Returns the active unit of work for the calling thread
      #
      # @raise [InvalidStateError] If there is no active unit of work
      # @return [Unit]
      def get
        unless active?
          raise InvalidStateError, 'No active unit of work for the calling thread'
        end

        stack.last
      end

      # Commits the active unit of work for the calling thread
      #
      # @raise [InvalidStateError] If there is no active unit of work
      # @return [undefined]
      def commit
        get.commit
      end

      # Rolls back the active unit of work for the calling thread
      #
      # @raise [InvalidStateError] If there is no active unit of work
      # @return [undefined]
      def rollback
        get.rollback
      end

      # Rolls back the entire stack of units of work
      # @return [undefined]
      def rollback_all
        rollback while active?
      end

      # Binds the given unit of work to the calling thread
      #
      # Other units of work bound to the calling thread, if any, will be treated as inactive
      # until the given unit of work is cleared.
      #
      # @param [Unit] unit
      # @return [undefined]
      def set(unit)
        stack.push unit
      end

      # Clears the current unit of work bound to the calling thread
      #
      # @raise [ArgumentError] If the given unit is not the current unit
      # @param [Unit] unit
      # @return [undefined]
      def clear(unit)
        unless stack.last == unit
          raise ArgumentError, 'The given unit of work is not the current unit of work'
        end

        stack.pop
      end

      # Clears the entire unit of work stack for the calling thread
      #
      # @api private
      # @return [undefined]
      def clear_all
        stack.clear
      end

      private

      # @return [Array]
      def stack
        Threaded[:current_unit] ||= Array.new
      end
    end # CurrentUnit
  end # UnitOfWork
end
