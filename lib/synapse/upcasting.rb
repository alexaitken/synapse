module Synapse
  module Upcasting
    extend ActiveSupport::Autoload

    autoload :SingleUpcaster
    autoload :Upcaster
    autoload :UpcasterChain, 'synapse/upcasting/chain'

    autoload_at 'synapse/upcasting/context' do
      autoload :UpcastingContext
      autoload :SerializedDomainEventUpcastingContext
    end

    autoload :UpcastSerializedDomainEventData, 'synapse/upcasting/data'
  end
end
