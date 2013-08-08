module Synapse
  # Base class for any framework-related exceptions
  class BaseError < StandardError; end

  # Raised when an operation failed due to an error that cannot be resolved without intervention.
  # Retrying the operation that raised the exception will most likely result in the same exception
  # being raised.
  #
  # This is usually caused by a programming bug or a version conflict.
  class NonTransientError < BaseError; end

  # Raised when an operation failed, but retrying the operation could resolve the error. Typically
  # the cause of the exception is of temporary nature and may be resolved without intervention.
  class TransientError < BaseError; end

  # Raised when an operation failed due to the application being in an invalid state
  class InvalidStateError < NonTransientError; end
end
