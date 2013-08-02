module Synapse
  module EventBus
    class SimpleCluster < BaseCluster
      # @api public
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
  end # EventBus
end
