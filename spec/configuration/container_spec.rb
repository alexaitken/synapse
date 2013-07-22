require 'spec_helper'
require 'configuration/fixtures/dependent'

module Synapse
  module Configuration

    describe Container do
      it 'injects services into a Dependent object' do
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

        dependent.service_a.should be(service_a)
        dependent.some_service.should be(service_b)
      end

      it 'does not attempt to inject services into a non-Dependent object' do
        container = Container.new
        object = Object.new

        container.inject_into object
      end

      it 'does not overwrite existing attributes when injecting into a Dependent object' do
        container = Container.new

        service_a = Object.new
        service_b = Object.new

        DefinitionBuilder.build container, :service_a do
          use_instance service_a
        end

        DefinitionBuilder.build container, :service_b do
          use_instance service_b
        end

        other_service_a = Object.new

        dependent = ExampleDependent.new
        dependent.service_a = other_service_a
        container.inject_into dependent

        dependent.service_a.should be(other_service_a)
        dependent.some_service.should be(service_b)
      end

      it 'resolves a service from a definition by its identifier' do
        reference = Object.new
        container = Container.new

        DefinitionBuilder.build container, :some_service do
          use_instance reference
        end

        container.resolve(:some_service).should be(reference)
      end

      it 'resolves a service from a definition by its tag' do
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
        container.resolve_tagged(:some_tag).should include(some_service)
      end

      it 'supports optional service resolution' do
        container = Container.new

        container.resolve(:some_service, true).should be_nil
        expect {
          container.resolve :some_service
        }.to raise_error(ConfigurationError)
      end

      it 'logs when a definition is replaced' do
        logger = Logging.logger[Container]

        mock(logger).info(anything)

        container = Container.new
        container.register :some_service, Object.new
        container.register :some_service, Object.new
      end
    end

  end
end
