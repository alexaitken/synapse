module Synapse
  module Wiring
    extend ActiveSupport::Autoload

    autoload :MessageWiring
    autoload :Wire
    autoload :WireRegistry
  end
end
