module Synapse
  module UnitOfWork
    # Entry point for components to access units of work. Components managing transactional
    # boundaries can register and clear unit of work instances.
    class UnitOfWorkProvider
      # @return [undefined]
      def initialize
        @threads = Hash.new
      end

      # Clears the given unit of work from this provider
      #
      # If the given unit of work is not known to the provider, or it is not the active unit
      # of work, then this method will raise an exception.
      #
      # @param [UnitOfWork] unit
      # @return [undefined]
      def clear(unit)
        unless stack.last == unit
          raise ArgumentError, 'The given unit of work is not the active unit of work'
        end

        stack.pop
      end

      # Commits the current unit of work
      # @return [undefined]
      def commit
        current.commit
      end

      # Returns the current unit of work if one is set
      #
      # @raise [RuntimeError] If no unit of work is active
      # @return [UnitOfWork]
      def current
        if stack.empty?
          raise 'No unit of work is active'
        end

        stack.last
      end

      # Pushes the given unit of work onto the top of the stack, making it the active unit of work
      #
      # If there are other units of work bound to this provider, they will be held until the given
      # unit of work is cleared.
      #
      # @param [UnitOfWork] unit
      # @return [undefined]
      def push(unit)
        stack.push unit
      end

      # Returns true if there is an active unit of work
      # @return [Boolean]
      def started?
        !stack.empty?
      end

      private

      # @return [Array<UnitOfWork>]
      def stack
        @threads.fetch Thread.current
      rescue KeyError
        @threads.store Thread.current, Array.new
      end
    end # UnitOfWorkProvider
  end # UnitOfWork
end
