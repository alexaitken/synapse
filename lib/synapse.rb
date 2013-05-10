require 'active_support'
require 'active_support/core_ext'
require 'eventmachine'
require 'logging'
require 'set'

require 'synapse/version'

module Synapse
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload_at 'synapse/common/errors' do
      autoload :SynapseError
      autoload :ConfigurationError
      autoload :NonTransientError
      autoload :TransientError
    end

    autoload_at 'synapse/common/identifier' do
      autoload :IdentifierFactory
      autoload :GuidIdentifierFactory
    end

    autoload :Message, 'synapse/common/message'
    autoload :MessageBuilder, 'synapse/common/message_builder'

    autoload_at 'synapse/common/duplication' do
      autoload :DuplicationError
      autoload :DuplicationRecorder
    end

    # Common components
    autoload :Command
    autoload :Domain
    autoload :EventBus
    autoload :Repository
    autoload :Serialization
    autoload :UnitOfWork, 'synapse/uow'
  end

  autoload :Auditing
  autoload :EventSourcing
  autoload :EventStore
  autoload :Partitioning
  autoload :ProcessManager
  autoload :Upcasting
  autoload :Wiring

  # TODO this is more of an application call
  ActiveSupport::Autoload.eager_autoload!

  # Setup the default identifier factory
  ActiveSupport.on_load :identifier_factory  do
    IdentifierFactory.instance = GuidIdentifierFactory.new
  end
end
