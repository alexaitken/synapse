module Synapse
  # Represents a mechanism for generating unique identifiers for domain objects
  # @abstract
  class IdentifierFactory
    include AbstractType

    # Returns a generated unique identifier
    #
    # @abstract
    # @return [String]
    abstract_method :generate
  end

  # Implementation of an identifier factory that the UUID generator from SecureRandom
  # @api public
  class UUIDIdentifierFactory < IdentifierFactory
    # @return [String]
    def generate
      SecureRandom.uuid
    end
  end
end
