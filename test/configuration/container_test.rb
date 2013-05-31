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

      should 'not attempt to inject services into a non-Dependent object' do
        container = Container.new
        object = Object.new

        container.inject_into object
      end

      should 'resolve a service from a definition by its identifier' do
        reference = Object.new
        container = Container.new

        DefinitionBuilder.build container, :some_service do
          use_instance reference
        end

        assert_same reference, container.resolve(:some_service)
      end

      should 'resolve a service from a definition by its tag' do
        container = Container.new
        some_service = Object.new
        some_other_service = Object.new

        DefinitionBuilder.build container, :some_service do
          tag :some_tag
          use_instance some_service
        end

        DefinitionBuilder.build container, :some_other_service do
          tag :some_other_tag
          use_instance some_other_service
        end

        # Do it breh
        tagged = container.resolve_tagged :some_tag
        assert tagged.include? some_service
      end

      should 'support optional service resolution' do
        container = Container.new

        assert_nil container.resolve :some_service, true
        assert_raise ArgumentError do
          container.resolve :some_service
        end
      end

      should 'log when a definition is replaced' do
        logger = Logging.logger[Container]

        mock(logger).info(anything)

        container = Container.new
        container.register :some_service, Object.new
        container.register :some_service, Object.new
      end

    end
  end
end
