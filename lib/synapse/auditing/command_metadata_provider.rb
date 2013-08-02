module Synapse
  module Auditing
    # Implementation of an audit provider that simply audits a command's metadata
    class CommandMetadataProvider < DataProvider
      # @param [CommandMessage] command
      # @return [Hash]
      def provide_data_for(command)
        command.metadata
      end
    end # CommandMetadataProvider
  end # Auditing
end
