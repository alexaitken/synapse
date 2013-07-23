require 'spec_helper'
require 'ostruct'

module Synapse
  module Upcasting
    describe UpcastSerializedDomainEventData do

      it 'delegates attributes' do
        delegate = OpenStruct.new
        delegate.id = SecureRandom.uuid
        delegate.metadata = Object.new
        delegate.payload = Object.new
        delegate.timestamp = Time.now
        delegate.aggregate_id = Object.new
        delegate.sequence_number = 123

        aggregate_id = Object.new
        upcast_payload = Object.new

        upcast = UpcastSerializedDomainEventData.new delegate, aggregate_id, upcast_payload

        # Assert delegated properties
        expect(upcast.id).to be(delegate.id)
        expect(upcast.metadata).to be(delegate.metadata)
        expect(upcast.payload).to be(upcast_payload)
        expect(upcast.timestamp).to be(delegate.timestamp)
        expect(upcast.aggregate_id).to be(aggregate_id)
        expect(upcast.sequence_number).to be(delegate.sequence_number)
      end

    end
  end
end
