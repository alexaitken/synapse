require 'spec_helper'

module Synapse
  module Configuration

    describe ContainerBuilder do
      before do
        # Backup any existing initializers
        @initializers = ContainerBuilder.initializers
        ContainerBuilder.initializers = nil

        # Create a container that will be built
        @container = Container.new
      end

      after do
        # Restore any existing initializers
        ContainerBuilder.initializers = @initializers
      end

      it 'calls initializers upon creation' do
        ContainerBuilder.initializer do
          definition :test_definition do
            tag :derp
          end
        end

        builder = ContainerBuilder.new @container

        @container.registered?(:test_definition).should be_true
      end

      it 'creates a simple definition from a factory' do
        reference = Object.new

        builder = ContainerBuilder.new @container
        builder.factory :derp_service, :tag => [:first_tag, :nth_tag] do
          reference
        end

        @container.registered?(:derp_service).should be_true
        @container.resolve(:derp_service).should == reference
        @container.resolve_tagged(:first_tag).should include(reference)
        @container.resolve_tagged(:nth_tag).should include(reference)
      end
    end

  end
end
