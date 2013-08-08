module Synapse
  module UnitOfWork
    # Base implementation of a unit of work that provides the necessary logic for nesting units
    # of work and registration with the unit of work stack.
    class NestableUnit < Unit
      include AbstractType
      include Loggable

      # @return [undefined]
      def initialize
        @active = false
        @inner_units = Array.new
      end

      # @api public
      # @raise [InvalidStateError] If this unit of work is already active
      # @return [undefined]
      def start
        logger.debug 'Starting unit of work'

        if active?
          raise InvalidStateError, 'Unit of work is already active'
        end

        perform_start
        if CurrentUnit.active?
          # This unit of work will be nested
          @outer_unit = CurrentUnit.get
          if @outer_unit.respond_to? :register_inner_unit
            @outer_unit.register_inner_unit self
          else
            # Outer unit is not aware of nesting, hook in with a commit listener
            @outer_unit.register_listener OuterCommitListener.new self
          end
        end

        logger.debug 'Binding this unit of work as the current unit of work'
        CurrentUnit.set self

        @active = true
      end

      # @api public
      # @raise [InvalidStateError] If this unit of work is not active
      # @return [undefined]
      def commit
        logger.debug 'Committing unit of work'
        ensure_active

        begin
          notify_prepare_commit
          store_aggregates

          if @outer_unit
            logger.debug 'Unit of work is nested, commit will be finalized by outer unit'
          else
            logger.debug 'Unit of work is not nested, finalizing commit'

            perform_commit
            stop
            perform_cleanup
          end
        rescue
          logger.debug 'Error occured while committing unit, performing rollback'

          perform_rollback $!
          stop
          perform_cleanup unless @outer_unit

          raise
        ensure
          clear
        end
      end

      # @api public
      # @param [Exception] cause
      # @return [undefined]
      def rollback(cause = nil)
        if cause
          # TODO log the cause
          logger.debug 'Rollback requested for unit of work due to exception'
        else
          logger.debug 'Rollback requested for unit of work due to unknown reason'
        end

        begin
          if active?
            perform_rollback cause
          end
        ensure
          perform_cleanup unless @outer_unit
          clear
          stop
        end
      end

      # @api public
      # @return [Boolean]
      def active?
        @active
      end

      # Registers a nested inner unit with this outer unit
      #
      # This method is public for nesting purposes
      #
      # @api private
      # @param [NestableUnit] inner_unit
      # @return [undefined]
      def register_inner_unit(inner_unit)
        @inner_units.push inner_unit
      end

      # Performs the logic necessary to cleanup resources for this unit of work
      #
      # This method is public for nesting purposes
      #
      # @api private
      # @return [undefined]
      def perform_cleanup
        @inner_units.each do |inner_unit|
          inner_unit.perform_cleanup
        end

        notify_cleanup
      end

      # This method is public for nesting purposes
      #
      # @api private
      # @param [Exception] cause
      # @return [undefined]
      def perform_inner_rollback(cause)
        logger.debug 'Rolling back inner unit of work'

        CurrentUnit.set self

        begin
          perform_rollback cause
        ensure
          clear
          stop
        end
      end

      # This method is public for nesting purposes
      #
      # @api private
      # @return [undefined]
      def perform_inner_commit
        logger.debug 'Finalizing commit of inner unit of work'

        CurrentUnit.set self

        begin
          perform_commit
        rescue
          perform_rollback $!
          raise
        ensure
          clear
          stop
        end
      end

      protected

      # Persists tracked aggregates by invoking their respective storage callbacks
      # @return [undefined]
      abstract_method :store_aggregates

      # Performs the logic necessary to start this unit of work
      # @return [undefined]
      abstract_method :perform_start

      # Performs the logic necessary to commit this unit of work
      # @return [undefined]
      abstract_method :perform_commit

      # Performs the logic necessary to rollback this unit of work
      #
      # @param [Exception] cause
      # @return [undefined]
      abstract_method :perform_rollback

      # Notifies registered listeners that the unit of work is being committed
      # @return [undefined]
      abstract_method :notify_prepare_commit

      # Notifies registered listeners that the unit of work is being cleaned up
      # @return [undefined]
      abstract_method :notify_cleanup

      # Commits registered inner units of work
      #
      # This should be invoked after buffered events have been published and before any listeners
      # are notified of the commit.
      #
      # @return [undefined]
      def commit_inner_units
        @inner_units.each do |inner_unit|
          if inner_unit.active?
            inner_unit.perform_inner_commit
          end
        end
      end

      # Rolls back registered inner units of work
      #
      # This should be invoked before any listeners are notified of the rollback
      #
      # @param [Exception] cause
      # @return [undefined]
      def rollback_inner_units(cause)
        @inner_units.each do |inner_unit|
          if inner_unit.active?
            inner_unit.perform_inner_rollback cause
          end
        end
      end

      private

      # @raise [InvalidStateError]
      # @return [undefined]
      def ensure_active
        unless active?
          raise InvalidStateError, 'Unit of work is not currently active'
        end
      end

      # @return [undefined]
      def clear
        logger.debug 'Unbinding this unit of work as the current unit of work'
        CurrentUnit.clear self
      end

      # @return [undefined]
      def stop
        logger.debug 'Stopping unit of work'
        @active = false
      end
    end # NestableUnit
  end # UnitOfWork
end
