module Synapse
  module Auditing
    # Provides relevant information to events for auditing purposes
    # @abstract
    class AuditDataProvider
      # Returns auditing information for the given command
      #
      # @abstract
      # @param [CommandMessage] command
      # @return [Hash]
      def provide_data_for(command); end
    end

    # Implementation of an audit provider that simply audits a command's metadata
    class CommandMetadataProvider < AuditDataProvider
      # @param [CommandMessage] command
      # @return [Hash]
      def provide_data_for(command)
        command.metadata
      end
    end

    # Implementation of an audit provider that attaches a command's identifier to each event
    # produced as a result of the execution of that command
    class CorrelationDataProvider < AuditDataProvider
      # The default key to use when correlating events with commands
      DEFAULT_KEY = :command_id

      # @param [Symbol] correlation_key
      # @return [undefined]
      def initialize(correlation_key = DEFAULT_KEY)
        @correlation_key = correlation_key
      end

      # @param [CommandMessage] command
      # @return [Hash]
      def provide_data_for(command)
        Hash[@correlation_key, command.id]
      end
    end
  end
end
