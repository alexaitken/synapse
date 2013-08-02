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

        upcast.id.should be(delegate.id)
        upcast.metadata.should be(delegate.metadata)
        upcast.payload.should be(upcast_payload)
        upcast.timestamp.should be(delegate.timestamp)
        upcast.aggregate_id.should be(aggregate_id)
        upcast.sequence_number.should be(delegate.sequence_number)
      end

    end
  end
end
