require 'logger'
require 'securerandom'

# 3rd party libraries
require 'abstract_type'
require 'contender'
require 'hamster'
require 'ref'
require 'thread_safe'

require 'synapse/version'

# Core extension
require 'synapse/core_ext/array'
require 'synapse/core_ext/class'
require 'synapse/core_ext/hash'
require 'synapse/core_ext/ref/weak_key_map'
require 'synapse/core_ext/thread_safe/cache'

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
  autoload :Mapping,       'synapse/mapping'
  autoload :Persistence,   'synapse/persistence'
  autoload :Serialization, 'synapse/serialization'
  autoload :UnitOfWork,    'synapse/unit_of_work'

  # An empty, immutable list provided by Hamster
  EMPTY_LIST = [].to_list
end
