module Synapse
  module Auditing
    # Implementation of an audit logger that does nothing
    class NullAuditLogger < AuditLogger
      # @return [undefined]
      def on_success(*)
        # This method is intentionally empty
      end

      # @return [undefined]
      def on_failure(*)
        # This method is intentionally empty
      end
    end # NullAuditLogger
  end # Auditing
end
