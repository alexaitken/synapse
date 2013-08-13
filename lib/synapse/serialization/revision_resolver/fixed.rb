module Synapse
  module Serialization
    # Implementation of a revision resolver that returns a fixed value. This could be an
    # application version number, for example
    class FixedRevisionResolver < RevisionResolver
      # @param [String] revision
      # @return [undefined]
      def initialize(revision)
        @revision = revision
      end

      # @param [Class] payload_type
      # @return [String]
      def revision_of(payload_type)
        @revision.to_s
      end
    end # FixedRevisionResolver
  end # Serialization
end
