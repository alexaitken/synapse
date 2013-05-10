module Synapse
  module Domain
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload_at 'synapse/domain/aggregate_root' do
        autoload :AggregateRoot
        autoload :AggregateIdentifierNotInitializedError
      end

      autoload :EventContainer

      autoload_at 'synapse/domain/message' do
        autoload :EventMessage
        autoload :DomainEventMessage
      end

      autoload_at 'synapse/domain/message_builder' do
        autoload :EventMessageBuilder
        autoload :DomainEventMessageBuilder
      end

      autoload_at 'synapse/domain/stream' do
        autoload :DomainEventStream
        autoload :EndOfStreamError
        autoload :SimpleDomainEventStream
      end
    end
  end
end
