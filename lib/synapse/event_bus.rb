module Synapse
  module EventBus
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload_at 'synapse/event_bus/event_bus' do
        autoload :EventBus
        autoload :SubscriptionFailedError
      end

      autoload :EventListener
      autoload :EventListenerProxy
      autoload :SimpleEventBus
      autoload :WiringEventListener, 'synapse/event_bus/wiring'
    end
  end
end
