require 'test_helper'

module Synapse
  module Configuration
    class ContainerTest < Test::Unit::TestCase

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
