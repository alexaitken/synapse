require 'test_helper'

module Synapse
  module Configuration
    class DefinitionTest < Test::Unit::TestCase

      def test_resolve
        tags = Set[:a, :b]
        instance = Object.new
        factory_invoked = 0
        factory = proc do
          factory_invoked += 1
        end

        # Prototype service definition
        definition = Definition.new tags, true, factory, nil
        definition.resolve
        definition.resolve
        assert_equal 2, factory_invoked

        # Singleton service definition
        definition = Definition.new tags, false, factory, nil
        definition.resolve
        definition.resolve
        assert_equal 3, factory_invoked

        # Singleton service definition w/ late instance
        definition = Definition.new tags, false, nil, instance
        assert_same instance, definition.resolve
      end

    end
  end
end
