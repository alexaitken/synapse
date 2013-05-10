module Synapse
  module Auditing
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :AuditLogger

      autoload_at 'synapse/auditing/data_provider' do
        autoload :AuditDataProvider
        autoload :CommandMetadataProvider
        autoload :CorrelationDataProvider
      end

      autoload :AuditingUnitOfWorkListener, 'synapse/auditing/unit_listener'
      autoload :AuditingDispatchInterceptor, 'synapse/auditing/dispatch_interceptor'
    end
  end
end
