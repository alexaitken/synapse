require 'test_helper'

module Synapse
  module Configuration
    class DefinitionBuilderTest < Test::Unit::TestCase
      def setup
        @container = Container.new
      end

      def test_build
        DefinitionBuilder.build @container, :some_id do
          # we'll pass here
        end
        assert @container.registered? :some_id
      end

      def test_identified_by
        DefinitionBuilder.build @container do
          identified_by :other_id
        end
        assert @container.registered? :other_id
      end

      def test_tag
        DefinitionBuilder.build @container, :derp_service do
          tag :one, :two
          use_instance 123
        end

        assert @container.registered? :derp_service
        assert_equal [123], @container.resolve_tagged(:one)
        assert_equal [123], @container.resolve_tagged(:two)
        assert_equal [], @container.resolve_tagged(:three)
      end

      def test_as_prototype
        DefinitionBuilder.build @container, :keygen do
          as_prototype
          use_factory do
            SecureRandom.uuid
          end
        end

        first = @container.resolve :keygen
        second = @container.resolve :keygen

        refute_equal first, second
      end

      def test_as_singleton
        DefinitionBuilder.build @container, :static_keygen do
          as_singleton
          use_factory do
            SecureRandom.uuid
          end
        end

        first = @container.resolve :static_keygen
        second = @container.resolve :static_keygen

        assert_equal first, second
      end

      def test_resolve
        DefinitionBuilder.build @container, :some_dependency do
          use_instance 123
        end

        DefinitionBuilder.build @container, :dependent do
          use_factory do
            resolve :some_dependency
          end
        end

        value = @container.resolve :dependent
        assert_equal 123, value

        DefinitionBuilder.build @container, :self_dependent do
          use_factory do
            resolve Hash.new
          end
        end

        value = @container.resolve :self_dependent
        assert value.is_a? Hash
      end

      def test_resolve_tagged
        DefinitionBuilder.build @container, :some_tagged_dependency do
          use_instance 123
          tag :dependency
        end

        DefinitionBuilder.build @container, :dependent do
          use_factory do
            resolve_tagged :dependency
          end
        end

        value = @container.resolve :dependent
        assert_equal [123], value
      end

      def test_build_composite
        DefinitionBuilder.build @container, :outside do
          build_composite do
            identified_by :inside
          end
        end

        assert @container.registered? :outside
        assert @container.registered? :inside
      end

      def test_register_definition_raises
        assert_raise RuntimeError do
          DefinitionBuilder.build @container
        end
      end
    end
  end
end
