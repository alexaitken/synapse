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
    end # AuditDataProvider
  end # Auditing
end
