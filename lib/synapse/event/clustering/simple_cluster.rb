module Synapse
  module Event
    class SimpleCluster < BaseCluster
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        return if @members.empty?

        events.each do |event|
          @members.each do |member|
            member.notify event
          end
        end
      end
    end # SimpleCluster
  end # Event
end
