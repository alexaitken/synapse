module Synapse
  module Command
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :CommandBus
      autoload :SimpleCommandBus

      autoload :CommandCallback
      autoload :CommandFilter
      autoload :CommandHandler

      autoload_at 'synapse/command/message' do
        autoload :CommandMessage
        autoload :CommandMessageBuilder
      end

      autoload :CommandGateway, 'synapse/command/gateway'

      autoload :DispatchInterceptor
      autoload :InterceptorChain

      autoload_at 'synapse/command/duplication' do
        autoload :DuplicationFilter
        autoload :DuplicationCleanupInterceptor
      end

      autoload_at 'synapse/command/errors' do
        autoload :CommandExecutionError
        autoload :CommandValidationError
        autoload :NoHandlerError
      end

      autoload_at 'synapse/command/filters/validation' do
        autoload :ActiveModelValidationFilter
        autoload :ActiveModelValidationError
      end

      autoload_at 'synapse/command/interceptors/serialization' do
        autoload :SerializationOptimizingInterceptor
        autoload :SerializationOptimizingListener
      end

      autoload_at 'synapse/command/rollback_policy' do
        autoload :RollbackPolicy
        autoload :RollbackOnAnyExceptionPolicy
      end

      autoload :WiringCommandHandler, 'synapse/command/wiring'
    end
  end
end
