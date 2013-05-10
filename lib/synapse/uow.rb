module Synapse
  module UnitOfWork
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload_at 'synapse/uow/nesting' do
        autoload :NestableUnitOfWork
        autoload :OuterCommitUnitOfWorkListener
      end

      autoload :StorageListener, 'synapse/uow/storage_listener'
      autoload :TransactionManager, 'synapse/uow/transaction_manager'
      autoload :UnitOfWork, 'synapse/uow/uow'
      autoload :UnitOfWorkFactory, 'synapse/uow/factory'
      autoload :UnitOfWorkListener, 'synapse/uow/listener'
      autoload :UnitOfWorkListenerCollection, 'synapse/uow/listener_collection'
      autoload :UnitOfWorkProvider, 'synapse/uow/provider'
    end
  end
end
