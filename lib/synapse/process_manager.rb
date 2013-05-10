module Synapse
  module ProcessManager
    extend ActiveSupport::Autoload

    autoload :Correlation
    autoload :CorrelationResolver
    autoload :CorrelationSet

    autoload :Process
  end
end
