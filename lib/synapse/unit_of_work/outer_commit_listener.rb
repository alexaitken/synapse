module Synapse
  module UnitOfWork
    # Unit listener that hooks a nested unit into an outer unit that is unaware of nesting
    # @api private
    class OuterCommitListener
      include UnitListener

      # @param [NestableUnit] inner_unit
      # @return [undefined]
      def initialize(inner_unit)
        @inner_unit = inner_unit
      end

      # @param [Unit] unit
      # @return [undefined]
      def after_commit(unit)
        @inner_unit.perform_inner_commit
      end

      # @param [Unit] unit
      # @param [Exception] cause
      # @return [undefined]
      def on_rollback(unit, cause = nil)
        @inner_unit.perform_inner_rollback cause
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_cleanup(unit)
        @inner_unit.perform_cleanup
      end
    end # OuterCommitListener
  end # UnitOfWork
end
