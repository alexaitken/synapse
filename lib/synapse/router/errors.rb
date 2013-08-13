module Synapse
  module Router
    class DuplicateHandlerError < NonTransientError; end
    class UnknownParameterTypeError < NonTransientError; end
  end
end
