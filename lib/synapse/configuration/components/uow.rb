module Synapse
  module Configuration
    # Extension to container builder that registers default services for the unit of work component
    class ContainerBuilder
      # Unit of work provider
      default do |service|
        service.id = :unit_provider
        service.with_factory do
          UnitOfWork::UnitOfWorkProvider.new
        end
      end

      # Unit of work factory, with optional transaction manager
      default do |service|
        service.id = :unit_factory
        service.with_factory do |container|
          provider = container.fetch :unit_provider
          transaction_manager = container.fetch :transaction_manager, true

          unit_factory = UnitOfWork::UnitOfWorkFactory.new provider
          unit_factory.tap do
            unit_factory.transaction_manager = transaction_manager
          end
        end
      end
    end # ContainerBuilder
  end # Configuration
end
