require 'abstract_type'
require 'securerandom'

require 'synapse/version'

# Core extension
require 'synapse/core_ext/hash'

# Common classes
require 'synapse/configuration'
require 'synapse/errors'
require 'synapse/identifier_factory'
require 'synapse/loggable'
require 'synapse/message'
require 'synapse/message_builder'
require 'synapse/threaded'

# Components
require 'synapse/event'
require 'synapse/domain'
require 'synapse/unit_of_work'

module Synapse
  extend Configuration
end
