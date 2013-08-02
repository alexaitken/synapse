module Synapse
  module Command
    # Represents a mechanism for scheduling the dispatch of a command in the future
    # @abstract
    class ScheduleProvider
      # @abstract
      # @param [Float] delay
      # @param [Proc] dispatcher
      # @return [undefined]
      def schedule_dispatch(delay, dispatcher)
        raise NotImplementedError
      end
    end # ScheduleProvider
  end # Command
end
