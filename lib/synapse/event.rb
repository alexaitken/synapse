require 'synapse/event/errors'
require 'synapse/event/event_bus'
require 'synapse/event/event_listener'
require 'synapse/event/event_listener_proxy'
require 'synapse/event/event_listener_proxy_aware'
require 'synapse/event/message'
require 'synapse/event/message_builder'
require 'synapse/event/routed_event_listener'
require 'synapse/event/simple_event_bus'

require 'synapse/event/clustering'

module Synapse
  module Event
    extend self

    # @yield [EventMessageBuilder]
    # @return [EventMessage]
    def build_message(&block)
      EventMessage.build &block
    end
  end
end
