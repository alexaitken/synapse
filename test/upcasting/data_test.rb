require 'test_helper'
require 'ostruct'

module Synapse
  module Upcasting
    class UpcastSerializedDomainEventDataTest < Test::Unit::TestCase

      should 'delegate properties correctly' do
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
        assert_same delegate.id, upcast.id
        assert_same delegate.metadata, upcast.metadata
        assert_same upcast_payload, upcast.payload
        assert_same delegate.timestamp, upcast.timestamp
        assert_same aggregate_id, upcast.aggregate_id
        assert_same delegate.sequence_number, upcast.sequence_number
      end

    end
  end
end
