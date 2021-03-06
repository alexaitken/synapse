require 'test_helper'

module Synapse
  module Serialization

    class SerializerTest < Test::Unit::TestCase
      should 'add revisions to serialized objects when a revision resolver is present' do
        revision = '123'

        serializer = Serializer.new ConverterFactory.new
        serializer.revision_resolver = FixedRevisionResolver.new revision

        type = serializer.type_for Object

        assert_equal revision, type.revision
      end
    end

  end
end
