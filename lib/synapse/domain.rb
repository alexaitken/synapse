require 'synapse/domain/aggregate_root'
require 'synapse/domain/errors'
require 'synapse/domain/event_container'
require 'synapse/domain/message'
require 'synapse/domain/message_builder'
require 'synapse/domain/stream'
require 'synapse/domain/simple_stream'

module Synapse
  module Domain
    extend self

    # @yield [DomainEventMessageBuilder]
    # @return [DomainEventMessage]
    def build_message(&block)
      DomainEventMessage.build &block
    end
  end
end
