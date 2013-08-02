require 'active_support'
require 'active_support/core_ext'
require 'atomic'
require 'bindata'
require 'contender'
require 'forwardable'
require 'logging'
require 'ref'
require 'set'
require 'thread_safe'

require 'synapse/version'
require 'synapse/core_ext'
require 'synapse/common'

module Synapse
  extend ActiveSupport::Autoload

  autoload :Auditing
  autoload :Command
  autoload :Domain
  autoload :EventBus
  autoload :EventSourcing
  autoload :EventStore
  autoload :Mapping
  autoload :Saga
  autoload :Repository
  autoload :Serialization
  autoload :UnitOfWork, 'synapse/uow'
  autoload :Upcasting
end

