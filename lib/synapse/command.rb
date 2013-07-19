module Synapse
  module Command
    extend ActiveSupport::Autoload

    autoload :AsynchronousCommandBus, 'synapse/command/async_command_bus'

    # Optional filters and interceptors
    autoload_at 'synapse/command/duplication' do
      autoload :DuplicationFilter
      autoload :DuplicationCleanupInterceptor
    end

    autoload_at 'synapse/command/filters/validation' do
      autoload :ActiveModelValidationFilter
      autoload :ActiveModelValidationError
    end

    autoload_at 'synapse/command/interceptors/serialization' do
      autoload :SerializationOptimizingInterceptor
      autoload :SerializationOptimizingListener
    end
  end
end

require 'synapse/command/command_bus'
require 'synapse/command/command_callback'
require 'synapse/command/command_filter'
require 'synapse/command/command_handler'
require 'synapse/command/dispatch_interceptor'
require 'synapse/command/errors'
require 'synapse/command/interceptor_chain'
require 'synapse/command/mapping'
require 'synapse/command/message'
require 'synapse/command/rollback_policy'
require 'synapse/command/simple_command_bus'

require 'synapse/command/gateway'
require 'synapse/command/gateway/retry_scheduler'
require 'synapse/command/gateway/interval_retry_scheduler'
require 'synapse/command/gateway/retrying_callback'

require 'synapse/command/callbacks/future'
require 'synapse/command/callbacks/void'
