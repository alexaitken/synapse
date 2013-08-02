module Synapse
  module Auditing
    # Provides relevant information to events for auditing purposes
    # @abstract
    class DataProvider
      # Returns auditing information for the given command
      #
      # @abstract
      # @param [CommandMessage] command
      # @return [Hash]
      def provide_data_for(command)
        raise NotImplementedError
      end
    end

    # Implementation of a data provider that returns an empty hash
    class EmptyDataProvider < DataProvider
      # @param [CommandMessage] command
      # @return [Hash]
      def provide_data_for(command)
        Hash.new
      end
    end # EmptyDataProvider
  end # Auditing
end
