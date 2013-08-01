require 'synapse/saga/correlation'
require 'synapse/saga/correlation_resolver'
require 'synapse/saga/correlation_set'
require 'synapse/saga/lock_manager'
require 'synapse/saga/pessimistic_lock_manager'
require 'synapse/saga/saga'
require 'synapse/saga/saga_factory'
require 'synapse/saga/saga_manager'
require 'synapse/saga/saga_repository'
require 'synapse/saga/resource_injector'
# Must be loaded after the resource injector
require 'synapse/saga/container_resource_injector'
require 'synapse/saga/simple_saga_manager'

require 'synapse/saga/mapping/saga'
require 'synapse/saga/mapping/saga_manager'

require 'synapse/saga/repository/in_memory'
