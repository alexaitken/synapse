require 'spec_helper'

module Synapse
  module Configuration

    describe Definition do
      it 'call the deferred factory every time if prototype' do
        factory_invoked = 0
        factory = proc do
          factory_invoked += 1
        end

        definition = Definition.new Set.new, true, factory, nil
        definition.resolve
        definition.resolve

        factory_invoked.should == 2
      end

      it 'call the deferred factory only once if singleton' do
        factory_invoked = 0
        factory = proc do
          factory_invoked += 1
        end

        definition = Definition.new Set.new, false, factory, nil
        definition.resolve
        definition.resolve

        factory_invoked.should == 1
      end

      it 'resolve to an instance if one is provided' do
        instance = Object.new

        # Singleton service definition w/ late instance
        definition = Definition.new Set.new, false, nil, instance
        definition.resolve.should be(instance)
      end
    end

  end
end
