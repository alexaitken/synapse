module Synapse
  module Saga
    # Combination key and value that is used to correlate incoming events with saga instance
    Correlation = Struct.new :key, :value
  end
end
