require 'synapse/configuration/container'
require 'synapse/configuration/container_builder'
require 'synapse/configuration/definition'
require 'synapse/configuration/definition_builder'
require 'synapse/configuration/ext'

# Pull in any configuration components
lib = File.dirname File.absolute_path __FILE__
components = File.join lib, 'configuration/component/**/*.rb'

Dir[components].each do |file|
  require file
end
