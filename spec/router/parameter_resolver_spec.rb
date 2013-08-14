require 'spec_helper'

module Synapse
  module Router

    describe PayloadParameterResolver do
      it 'resolves a payload for the first parameter' do
        message = Message.build do |builder|
          builder.payload = Object.new
        end

        expect(subject.can_resolve?(0, :derp)).to be_true
        subject.resolve(message).should == message.payload
      end
    end

    describe MessageParameterResolver do
      it 'resolves a message for parameters named :message' do
        message = Object.new

        expect(subject.can_resolve?(1, :message)).to be_true
        subject.resolve(message).should == message
      end
    end

    describe TimestampParameterResolver do
      it 'resolves a timestamp for parameters named :timestamp' do
        message = Message.build

        expect(subject.can_resolve?(1, :timestamp)).to be_true
        subject.resolve(message).should == message.timestamp
      end
    end

    describe MetadataParameterResolver do
      it 'resolves a timestamp for parameters named :metadata' do
        message = Message.build

        expect(subject.can_resolve?(1, :metadata)).to be_true
        subject.resolve(message).should == message.metadata
      end
    end

    describe AggregateIdParameterResolver do
      it 'resolves an aggregate identifier for parameters named :aggregate_id' do
        message = Domain.build_message do |builder|
          builder.aggregate_id = Object.new
        end

        expect(subject.can_resolve?(1, :aggregate_id)).to be_true
        subject.resolve(message).should == message.aggregate_id
      end
    end

    describe SequenceNumberParameterResolver do
      it 'resolves a sequence number for parameters named :sequence_number' do
        message = Domain.build_message do |builder|
          builder.sequence_number = 19
        end

        expect(subject.can_resolve?(1, :sequence_number)).to be_true
        subject.resolve(message).should == message.sequence_number
      end
    end

    describe CurrentUnitParameterResolver do
      it 'resolves the current unit of work for parameters named as such' do
        unit = Object.new
        stub(UnitOfWork).current.returns(unit)

        [:unit, :current_unit, :uow, :current_uow].each do |name|
          expect(subject.can_resolve?(1, name)).to be_true
        end

        subject.resolve(Object.new).should == unit
      end
    end

    describe ResourceParameterResolver do
      it 'resolves a resource for parameters with matching name' do
        names = [:a, :b]
        resource = Object.new

        subject = described_class.new resource, *names
        names.each do |name|
          expect(subject.can_resolve?(1, name)).to be_true
        end

        subject.resolve(Object.new).should == resource
      end
    end

  end
end
