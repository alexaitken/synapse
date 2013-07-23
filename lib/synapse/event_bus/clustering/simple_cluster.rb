module Synapse
  module EventBus
    class SimpleCluster < BaseCluster
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        events.flatten!

        events.each do |event|
          @members.each do |member|
            member.notify event
          end
        end
      end
    end # SimpleCluster
  end # EventBus
end
