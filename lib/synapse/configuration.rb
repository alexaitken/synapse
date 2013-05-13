require 'synapse/configuration/container'
require 'synapse/configuration/container_builder'
require 'synapse/configuration/service_definition'
require 'synapse/configuration/service_definition_builder'

# Load in all components that will contribute to the container builder
lib = File.dirname File.absolute_path __FILE__
components = File.join lib, 'configuration/components/**/*.rb'

Dir[components].each do |file|
  require file
end
