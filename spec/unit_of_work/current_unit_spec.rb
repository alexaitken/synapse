require 'spec_helper'

module Synapse
  module UnitOfWork

    describe CurrentUnit do
      after do
        CurrentUnit.clear_all
      end

      it 'returns the currently active unit of work' do
        expect {
          CurrentUnit.get
        }.to raise_error InvalidStateError

        unit = Object.new
        CurrentUnit.set unit

        CurrentUnit.get.should == unit
      end

      it 'only allows the current unit of work to be cleared' do
        unit_a = Object.new
        unit_b = Object.new

        CurrentUnit.set unit_a
        CurrentUnit.set unit_b

        CurrentUnit.should be_active

        expect {
          CurrentUnit.clear unit_a
        }.to raise_error ArgumentError

        CurrentUnit.clear unit_b
        CurrentUnit.should be_active

        CurrentUnit.clear unit_a
        CurrentUnit.should_not be_active
      end

      it 'maintains a separate stack per thread' do
        unit = Object.new
        CurrentUnit.set unit
        CurrentUnit.should be_active

        t = Thread.new do
          CurrentUnit.should_not be_active
        end

        t.join
      end

      it 'commits the current unit of work' do
        unit_a = Object.new
        unit_b = Object.new

        mock(unit_b).commit

        CurrentUnit.set unit_a
        CurrentUnit.set unit_b

        CurrentUnit.commit
      end

      it 'rolls back the current unit of work' do
        unit_a = Object.new
        unit_b = Object.new

        mock(unit_b).rollback

        CurrentUnit.set unit_a
        CurrentUnit.set unit_b

        CurrentUnit.rollback
      end
    end

  end
end
