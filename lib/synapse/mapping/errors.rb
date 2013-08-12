module Synapse
  module Mapping
    class DuplicateHandlerError < NonTransientError; end
    class UnknownParameterTypeError < NonTransientError; end
  end
end
