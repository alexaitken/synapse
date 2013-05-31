require 'active_support'
require 'active_support/core_ext'
require 'logging'
require 'set'

require 'synapse/common'
require 'synapse/version'

module Synapse
  extend ActiveSupport::Autoload

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
  autoload :Configuration
  autoload :EventSourcing
  autoload :EventStore
  autoload :ProcessManager
  autoload :Upcasting
end
