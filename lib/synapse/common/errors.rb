module Synapse
  # Base exception for all Synapse framework-related errors
  class SynapseError < RuntimeError; end

  # Raised when an error has occured that resulted from misconfiguration
  class ConfigurationError < SynapseError; end

  # Raised when an error has occured that cannot be resolved without intervention
  class NonTransientError < SynapseError; end

  # Raised when an error has occured that might be resolved by retrying the operation
  class TransientError < SynapseError; end

  # Raised when an imminent deadlock is detected
  #
  # It is typically safe to retry an operation if it resulted in this exception
  class DeadlockError < TransientError; end
end
