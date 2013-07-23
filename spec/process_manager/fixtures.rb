module Synapse
  module ProcessManager
    class StubProcess < Process
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
