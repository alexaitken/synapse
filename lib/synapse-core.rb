require 'active_support'
require 'active_support/core_ext'
require 'atomic'
require 'bindata'
require 'contender'
require 'forwardable'
require 'logging'
require 'ref'
require 'set'

require 'synapse/common'
require 'synapse/version'

module Synapse
  extend ActiveSupport::Autoload

  autoload :Auditing
  autoload :Command
  autoload :Configuration
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

