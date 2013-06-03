require 'synapse/configuration/component/repository/locking_repository'
require 'synapse/configuration/component/repository/simple_repository'

module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures a simple repository
      builder :simple_repository, SimpleRepositoryDefinitionBuilder
    end # ContainerBuilder
  end # Configuration
end
