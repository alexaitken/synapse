require 'active_support'
require 'active_support/core_ext'
require 'logging'
require 'set'

require 'synapse/version'

require 'synapse/common/errors'
require 'synapse/common/identifier'
require 'synapse/common/message'
require 'synapse/common/message_builder'

module Synapse
  extend ActiveSupport::Autoload

  autoload_at 'synapse/common/duplication' do
    autoload :DuplicationError
    autoload :DuplicationRecorder
  end

  eager_autoload do
    # Common components
    autoload :Command
    autoload :Domain
    autoload :EventBus
    autoload :Repository
    autoload :Serialization
    autoload :UnitOfWork, 'synapse/uow'
    autoload :Wiring
  end

  # Optional components
  autoload :Auditing
  autoload :EventSourcing
  autoload :EventStore
  autoload :Partitioning
  autoload :ProcessManager
  autoload :Upcasting
end
