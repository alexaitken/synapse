module Synapse
  module EventStore
    extend ActiveSupport::Autoload

    autoload :InMemoryEventStore, 'synapse/event_store/in_memory'
    autoload :Mongo
  end
end

require 'synapse/event_store/errors'
require 'synapse/event_store/event_store'
