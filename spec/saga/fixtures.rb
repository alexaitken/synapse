module Synapse
  module Saga
    class StubSaga < Saga
      def cause_finish
        finish
      end

      def cause_correlate(key, value)
        correlate_with key, value
      end

      def cause_dissociate(key, value)
        dissociate_from key, value
      end
    end
  end
end
