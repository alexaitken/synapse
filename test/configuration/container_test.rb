require 'test_helper'
require 'configuration/fixtures/dependent'

module Synapse
  module Configuration
    class ContainerTest < Test::Unit::TestCase

      should 'inject services into a Dependent object' do
        container = Container.new

        service_a = Object.new
        service_b = Object.new

        DefinitionBuilder.build container, :service_a do
          use_instance service_a
        end

        DefinitionBuilder.build container, :service_b do
          use_instance service_b
        end

        dependent = ExampleDependent.new
        container.inject_into dependent

        assert_same service_a, dependent.service_a
        assert_same service_b, dependent.some_service
      end

      def test_resolve
        reference = Object.new
        definition = Object.new
        mock(definition).resolve do
          reference
        end

        container = Container.new
        container.register :some_service, definition

        assert_same reference, container.resolve(:some_service)
      end

      def test_resolve_tagged
        # First definition
        reference = Object.new
        definition = Object.new
        mock(definition).resolve do
          reference
        end
        mock(definition).tags.any_times do
          Set.new << :some_tag
        end

        # Second definition
        other_definition = Object.new
        mock(other_definition).tags.any_times do
          Set.new << :some_other_tag
        end

        # Register with container
        container = Container.new
        container.register :some_service, definition
        container.register :some_other_service, other_definition

        # Do it breh
        tagged = container.resolve_tagged :some_tag
        assert tagged.include? reference
      end

      def test_resolve_optional
        container = Container.new

        assert_nil container.resolve :some_service, true
        assert_raise ArgumentError do
          container.resolve :some_service
        end
      end

      def test_double_register
        logger = Logging.logger[Container]

        mock(logger).info(anything)

        container = Container.new
        container.register :some_service, Object.new
        container.register :some_service, Object.new
      end

    end
  end
end
