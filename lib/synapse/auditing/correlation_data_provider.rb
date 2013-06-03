module Synapse
  module Auditing
    # Implementation of an audit provider that attaches a command's identifier to each event
    # produced as a result of the execution of that command
    class CorrelationDataProvider < AuditDataProvider
      # @param [Symbol] correlation_key
      # @return [undefined]
      def initialize(correlation_key)
        @correlation_key = correlation_key
      end

      # @param [CommandMessage] command
      # @return [Hash]
      def provide_data_for(command)
        Hash[@correlation_key, command.id]
      end
    end # CorrelationDataProvider
  end # Auditing
end
