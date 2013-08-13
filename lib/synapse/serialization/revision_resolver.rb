module Synapse
  module Serialization
    # Represents a mechanism for determining the revision of a payload being serialized
    class RevisionResolver
      include AbstractType

      # Determines the revision of the given payload type
      #
      # @param [Class] payload_type
      # @return [String]
      abstract_method :revision_of
    end # RevisionResolver
  end # Serialization
end
