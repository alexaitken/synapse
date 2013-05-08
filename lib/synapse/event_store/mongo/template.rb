module Synapse
  module EventStore
    module Mongo
      # Represents a mechanism for accessing collections required by the Mongo event store
      # @abstract
      class MongoTemplate
        # Returns a reference to the collection containing domain events
        #
        # @abstract
        # @return [Mongo::Collection]
        def event_collection; end

        # Returns a reference to the collection containing snapshot events
        #
        # @abstract
        # @return [Mongo::Collection]
        def snapshot_collection; end
      end

      class DefaultMongoTemplate
        # @return [String] Name of the database to use
        attr_accessor :database_name

        # @return [String] Username to authenticate with (optional)
        attr_accessor :username

        # @return [String] Password to authenticate with (optional)
        attr_accessor :password

        # @return [String] Name of the collection containing domain events
        attr_accessor :event_collection

        # @return [String] Name of the collection containing snapshot events
        attr_accessor :snapshot_collection

        # @param [Mongo::MongoClient] client
        # @return [undefined]
        def initialize(client)
          @client = client

          @database_name = 'synapse'
          @event_collection_name = 'domain_events'
          @snapshot_collection_name = 'snapshot_events'
        end

        # @return [Mongo::Collection]
        def event_collection
          database.collection @event_collection_name
        end

        # @return [Mongo::Collection]
        def snapshot_collection
          database.collection @snapshot_collection_name
        end

      private

        # @return [Mongo::DB]
        def database
          unless @database
            @database = @client.db @database_name

            if @username and @password
              @database.authenticate @username, @password
            end
          end

          @database
        end
      end # DefaultMongoTemplate
    end # Mongo
  end # EventStore
end # Synapse
