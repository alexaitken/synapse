require 'test_helper'

module Synapse
  module Configuration
    describe Definition do

      should 'call the defrred factory every time if prototype' do
        factory_invoked = 0
        factory = proc do
          factory_invoked += 1
        end

        definition = Definition.new Set.new, true, factory, nil
        definition.resolve
        definition.resolve
        assert_equal 2, factory_invoked
      end

      should 'call the deferred factory only once if singleton' do
        factory_invoked = 0
        factory = proc do
          factory_invoked += 1
        end

        definition = Definition.new Set.new, false, factory, nil
        definition.resolve
        definition.resolve
        assert_equal 1, factory_invoked
      end

      should 'resolve to an instance if one is provided' do
        instance = Object.new

        # Singleton service definition w/ late instance
        definition = Definition.new Set.new, false, nil, instance
        assert_same instance, definition.resolve
      end

    end
  end
end
