require 'uuidtools'

module Synapse
  # Represents a mechanism for generating a unique identifier for domain objects
  class IdentifierFactory
    class_attribute :instance
  end

  # Implementation of an identifier factory that generates pseudo-random GUIDs
  #
  # @example The identifier format produced by this factory
  #   factory = GuidIdentifierFactory.new
  #   factory.generate # => "8f0c580b-5a0f-4fc7-9025-c39072ae073d"
  class GuidIdentifierFactory
    # Generates a pseudo-random GUID
    # @return [String] The newly generated unique identifier
    def generate
      UUIDTools::UUID.random_create.to_s
    end
  end

  ActiveSupport.run_load_hooks :identifier_factory, IdentifierFactory
end
