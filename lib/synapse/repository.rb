module Synapse
  module Repository
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload_at 'synapse/repository/errors' do
        autoload :AggregateNotFoundError
        autoload :ConcurrencyError
        autoload :ConflictingAggregateVersionError
        autoload :ConflictingModificationError
      end

      autoload_at 'synapse/repository/lock_manager' do
        autoload :LockManager
        autoload :NullLockManager
      end

      autoload :PessimisticLockManager

      autoload_at 'synapse/repository/locking' do
        autoload :LockingRepository
        autoload :LockCleaningUnitOfWorkListener
      end

      autoload :Repository
    end
  end
end
