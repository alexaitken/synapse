module Synapse
  module ProcessManager
    # Combination key and value that is used to correlate incoming events with process instance
    Correlation = Struct.new :key, :value
  end
end
