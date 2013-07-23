require 'spec_helper'

module Synapse
  module EventBus

    describe SimpleEventBus do
      it 'publishes events to subscribed listeners' do
        listener = Object.new
        event = Object.new

        mock(listener).notify(event).once

        subject.publish event

        subject.subscribe listener
        subject.publish event

        subject.unsubscribe listener
        subject.publish event
      end
    end

  end
end
