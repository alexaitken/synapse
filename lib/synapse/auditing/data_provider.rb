module Synapse
  module Auditing
    # Provides relevant information to events for auditing purposes
    class DataProvider
      include AbstractType

      # Returns auditing information for the given command
      #
      # @param [CommandMessage] command
      # @return [Hash]
      abstract_method :provide_data_for
    end

    # Implementation of a data provider that returns an empty hash
    class EmptyDataProvider < DataProvider
      # @return [Hash]
      def provide_data_for(*)
        {}
      end
    end # EmptyDataProvider
  end # Auditing
end
