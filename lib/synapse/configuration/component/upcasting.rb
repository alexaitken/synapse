require 'synapse/configuration/component/upcasting/upcaster_chain'

module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures an upcaster chain
      builder :upcaster_chain, UpcasterChainDefinitionBuilder
    end # ContainerBuilder
  end # Configuration
end
