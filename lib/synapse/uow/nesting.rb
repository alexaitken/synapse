module Synapse
  module UnitOfWork
    # Partial implementation of a unit of work that can be nested
    #
    # This implementation provides common actions that will be needed for nestable units
    # of work, such as registration with the unit of work provider and nested commit
    # and rollback operations
    #
    # @abstract
    class NestableUnitOfWork
      # @param [UnitOfWorkProvider] provider
      # @return [undefined]
      def initialize(provider)
        @inner_units = Array.new
        @provider = provider
        @started = false
      end

      # Commits this unit of work
      #
      # All reigstered aggregates that have not been registered as stored are saved in their
      # respective repositories, buffered events are sent to their respective event buses, and
      # all registered listeners are notified of the commit.
      #
      # After the commit (successful or not), the unit of work is unregistered and cleans up any
      # resources it acquired. The effectively means that a rollback is done if the unit of work
      # failed to commit.
      #
      # @raise [RuntimeError] If unit of work hasn't been started yet
      # @return [undefined]
      def commit
        unless started?
          raise 'Unit of work has not been started yet'
        end

        begin
          notify_prepare_commit
          store_aggregates

          unless @outer_unit
            perform_commit
            stop
            perform_cleanup
          end
        rescue => cause
          perform_rollback cause
          stop

          unless @outer_unit
            perform_cleanup
          end

          raise cause
        ensure
          clear
        end
      end

      # Clears this unit of work of any buffered changes
      #
      # Any buffered events and registered aggregates are discarded and any registered unit of work
      # listeners are notified of the rollback.
      #
      # @param [Error] cause
      # @return [undefined]
      def rollback(cause = nil)
        begin
          if started?
            @inner_units.each do |inner_unit|
              @provider.push inner_unit
              inner_unit.rollback cause
            end
            perform_rollback cause
          end
        ensure
          finalize_rollback
        end
      end

      # Starts the unit of work, preparing it for aggregate registration
      #
      # @raise [RuntimeError] If unit of work has already been started
      # @return [undefined]
      def start
        if started?
          raise 'Unit of work has already been started'
        end

        perform_start

        if @provider.started?
          # This is a nested unit of work
          @outer_unit = @provider.current

          if NestableUnitOfWork === @outer_unit
            @outer_unit.register_inner_unit self
          else
            # Outer unit is not aware of inner units, hook in with a listener
            @outer_unit.register_listener OuterCommitUnitOfWorkListener.new self, @provider
          end
        end

        @provider.push self
        @started = true
      end

      # Returns true if this unit of work has been started
      # @return [Boolean]
      def started?
        @started
      end

    protected

      # Executes logic required to commit this unit of work
      #
      # @abstract
      # @return [undefined]
      def perform_commit; end

      # Executes logic required to rollback this unit of work
      #
      # @abstract
      # @param [Error] cause
      # @return [undefined]
      def perform_rollback(cause = nil); end

      # Notifies listeners that this unit of work is cleaning up
      #
      # @abstract
      # @return [undefined]
      def notify_cleanup; end

      # Notifies listeners that this unit of work is preparing to be committed
      #
      # @abstract
      # @return [undefined]
      def notify_prepare_commit; end

      # Executes logic required when starting this unit of work
      #
      # @abstract
      # @return [undefined]
      def perform_start; end

      # Storages aggregates registered with this unit of work
      #
      # @abstract
      # @return [undefined]
      def store_aggregates; end

      # Commits all registered inner units of work. This should be invoked after events have been
      # dispatched and before any listeners are notified of the commit.
      #
      # @return [undefined]
      def commit_inner_units
        @inner_units.each do |inner_unit|
          if inner_unit.started?
            inner_unit.perform_inner_commit
          end
        end
      end

      # Registers a unit of work nested in this unit of work
      #
      # @private
      # @param [UnitOfWork] inner_unit
      # @return [undefined]
      def register_inner_unit(inner_unit)
        @inner_units.push inner_unit
      end

      # Executes logic required to clean up this unit of work
      #
      # @private
      # @return [undefined]
      def perform_cleanup
        @inner_units.each do |inner_unit|
          inner_unit.perform_cleanup
        end

        notify_cleanup
      end

      # Commits this unit of work as an inner unit of work
      #
      # @private
      # @return [undefined]
      def perform_inner_commit
        @provider.push self

        begin
          perform_commit
        rescue => cause
          perform_rollback cause
        end

        clear
        stop
      end

    private

      # @return [undefined]
      def finalize_rollback
        unless @outer_unit
          perform_cleanup
        end

        clear
        stop
      end

      # @return [undefined]
      def clear
        @provider.clear self
      end

      # @return [undefined]
      def stop
        @started = false
      end
    end

    # Listener that allows a nested unit of work to properly operate within in a unit of
    # work that is not aware of nesting
    class OuterCommitUnitOfWorkListener < UnitOfWorkListener
      # @param [UnitOfWork] inner_unit
      # @param [UnitOfWorkProvider] provider
      # @return [undefined]
      def initialize(inner_unit, provider)
        @inner_unit = inner_unit
        @provider = provider
      end

      # @param [UnitOfWork] outer_unit
      # @return [undefined]
      def after_commit(outer_unit)
        @inner_unit.perform_inner_commit
      end

      # @param [UnitOfWork] outer_unit
      # @param [Error] cause
      # @return [undefined]
      def on_rollback(outer_unit, cause = nil)
        @provider.push @inner_unit

        begin
          @inner_unit.perform_rollback cause
        ensure
          @provider.clear @inner_unit
        end
      end

      # @param [UnitOfWork] outer_unit
      # @return [undefined]
      def on_cleanup(outer_unit)
        @inner_unit.perform_cleanup
      end
    end
  end
end
