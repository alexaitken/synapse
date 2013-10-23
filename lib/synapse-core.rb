require 'logger'
require 'securerandom'
require 'singleton'

# 3rd party libraries
require 'abstract_type'
require 'active_support'
require 'active_support/core_ext'
require 'adamantium'
require 'contender'
require 'equalizer'
require 'ref'
require 'thread_safe'

require 'synapse/version'
require 'synapse/core_ext'

# Common classes
require 'synapse/configuration'
require 'synapse/errors'
require 'synapse/identifier_factory'
require 'synapse/loggable'
require 'synapse/message'
require 'synapse/message_builder'
require 'synapse/threaded'

module Synapse
  extend Configuration

  # Core components
  autoload :Auditing,      'synapse/auditing'
  autoload :Command,       'synapse/command'
  autoload :Concurrent,    'synapse/concurrent'
  autoload :Domain,        'synapse/domain'
  autoload :Event,         'synapse/event'
  autoload :EventSourcing, 'synapse/event_sourcing'
  autoload :EventStore,    'synapse/event_store'
  autoload :Router,        'synapse/router'
  autoload :Persistence,   'synapse/persistence'
  autoload :Saga,          'synapse/saga'
  autoload :Serialization, 'synapse/serialization'
  autoload :UnitOfWork,    'synapse/unit_of_work'
end
