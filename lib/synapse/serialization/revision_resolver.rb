module Synapse
  module Serialization
    # Represents a mechanism for determining the revision of a payload being serialized
    # @abstract
    class RevisionResolver
      # Determines the revision of the given payload type
      #
      # @abstract
      # @param [Class] payload_type
      # @return [String] The revision of the given payload type
      def revision_of(payload_type); end
    end # RevisionResolver

    # Implementation of a revision resolver that returns a fixed value. This could be an
    # application version number, for example
    class FixedRevisionResolver < RevisionResolver
      # @param [String] revision
      # @return [undefined]
      def initialize(revision)
        @revision = revision
      end

      # @param [Class] payload_type
      # @return [String] Returns the fixed revision
      def revision_of(payload_type)
        @revision.to_s
      end
    end # FixedRevisionResolver
  end # Serialization
end
