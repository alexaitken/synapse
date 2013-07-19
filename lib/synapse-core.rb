require 'active_support'
require 'active_support/core_ext'
require 'atomic'
require 'contender'
require 'forwardable'
require 'logging'
require 'ref'
require 'set'

require 'synapse/common'
require 'synapse/version'

module Synapse
  # Core components
  autoload :Command, 'synapse/command'
  autoload :Domain, 'synapse/domain'
  autoload :EventBus, 'synapse/event_bus'
  autoload :Mapping, 'synapse/mapping'
  autoload :Repository, 'synapse/repository'
  autoload :Serialization, 'synapse/serialization'
  autoload :UnitOfWork, 'synapse/uow'

  # Optional components
  autoload :Auditing, 'synapse/auditing'
  autoload :Configuration, 'synapse/configuration'
  autoload :EventSourcing, 'synapse/event_sourcing'
  autoload :EventStore, 'synapse/event_store'
  autoload :ProcessManager, 'synapse/process_manager'
  autoload :Upcasting, 'synapse/upcasting'
end

