require 'active_support'
require 'active_support/core_ext'
require 'forwardable'
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
    autoload :Mapping
    autoload :Repository
    autoload :Serialization
    autoload :UnitOfWork, 'synapse/uow'
  end

  # Optional components
  autoload :Auditing
  autoload :Configuration
  autoload :EventSourcing
  autoload :EventStore
  autoload :ProcessManager
  autoload :Upcasting
end
