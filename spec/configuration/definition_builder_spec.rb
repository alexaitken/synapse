require 'spec_helper'

module Synapse
  module Configuration

    describe DefinitionBuilder do
      before do
        @container = Container.new
      end

      it 'builds a definition with just an identifier' do
        DefinitionBuilder.build @container, :some_id do
          # we'll pass here
        end
        @container.registered?(:some_id).should be_true
      end

      it 'builds a definition using an identifier set in the block' do
        DefinitionBuilder.build @container do
          identified_by :other_id
        end
        @container.registered?(:other_id).should be_true
      end

      it 'builds a definition using tags set in the block' do
        reference = Object.new

        DefinitionBuilder.build @container, :derp_service do
          tag :one, :two
          use_instance reference
        end

        @container.registered?(:derp_service).should be_true
        @container.resolve_tagged(:one).should include(reference)
        @container.resolve_tagged(:two).should include(reference)
        @container.resolve_tagged(:three).should be_empty
      end

      it 'builds a prototype definition using a factory' do
        DefinitionBuilder.build @container, :keygen do
          as_prototype
          use_factory do
            SecureRandom.uuid
          end
        end

        first = @container.resolve :keygen
        second = @container.resolve :keygen

        first.should_not == second
      end

      it 'builds a singleton definition using a factory' do
        DefinitionBuilder.build @container, :static_keygen do
          as_singleton
          use_factory do
            SecureRandom.uuid
          end
        end

        first = @container.resolve :static_keygen
        second = @container.resolve :static_keygen

        first.should == second
      end

      it 'delegates resolution to the service container' do
        reference = Object.new

        DefinitionBuilder.build @container, :some_dependency do
          use_instance reference
        end

        DefinitionBuilder.build @container, :dependent do
          use_factory do
            resolve :some_dependency
          end
        end

        @container.resolve(:dependent).should be(reference)

        DefinitionBuilder.build @container, :self_dependent do
          use_factory do
            resolve Hash.new
          end
        end

        @container.resolve(:self_dependent).should be_a(Hash)
      end

      it 'delegates tag resolution to the service container' do
        reference = Object.new

        DefinitionBuilder.build @container, :some_tagged_dependency do
          use_instance reference
          tag :dependency
        end

        DefinitionBuilder.build @container, :dependent do
          use_factory do
            resolve_tagged :dependency
          end
        end

        @container.resolve(:dependent).should include(reference)
      end

      it 'delegates building child services to another builder' do
        DefinitionBuilder.build @container, :outside do
          build_composite do
            identified_by :inside
          end
        end

        @container.registered?(:outside).should be_true
        @container.registered?(:inside).should be_true
      end

      it 'raises an exception if no identifier is set when registering with the container' do
        expect {
          DefinitionBuilder.build @container
        }.to raise_error(ConfigurationError)
      end
    end

  end
end
