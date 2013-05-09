require 'test_helper'

module Synapse
  module Serialization

    class SerializerTest < Test::Unit::TestCase
      def test_revision
        revision = '123'

        serializer = Serializer.new
        serializer.revision_resolver = FixedRevisionResolver.new revision

        type = serializer.type_for Object

        assert_equal revision, type.revision
      end
    end

  end
end
