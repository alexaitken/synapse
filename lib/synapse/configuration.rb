require 'synapse/configuration/container'
require 'synapse/configuration/container_builder'
require 'synapse/configuration/definition'
require 'synapse/configuration/definition_builder'
require 'synapse/configuration/dependent'
require 'synapse/configuration/ext'

require 'synapse/configuration/component/command_bus'
# Has to be loaded before asynchronous command bus definition builder
require 'synapse/configuration/component/command_bus/simple_command_bus'
require 'synapse/configuration/component/command_bus/async_command_bus'

require 'synapse/configuration/component/event_bus'
require 'synapse/configuration/component/event_bus/simple_event_bus'

require 'synapse/configuration/component/repository'
# Has to be loaded before event sourcing or simple repository definition builders
require 'synapse/configuration/component/repository/locking_repository'
require 'synapse/configuration/component/repository/simple_repository'

require 'synapse/configuration/component/event_sourcing'
require 'synapse/configuration/component/event_sourcing/repository'

require 'synapse/configuration/component/serialization'
require 'synapse/configuration/component/serialization/converter_factory'
require 'synapse/configuration/component/serialization/serializer'

require 'synapse/configuration/component/uow'
require 'synapse/configuration/component/uow/unit_factory'

require 'synapse/configuration/component/upcasting'
require 'synapse/configuration/component/upcasting/upcaster_chain'
