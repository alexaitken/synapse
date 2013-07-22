require 'spec_helper'

module Synapse
  module UnitOfWork

    describe OuterCommitUnitOfWorkListener do
      before do
        @provider = Object.new
        @outer_unit = Object.new
        @inner_unit = Object.new
        @listener = OuterCommitUnitOfWorkListener.new @inner_unit, @provider
      end

      it 'commits the inner unit if the outer unit is committed' do
        mock(@inner_unit).perform_inner_commit
        @listener.after_commit @outer_unit
      end

      it 'rolls back the inner unit if the outer unit is rolled back' do
        cause = TestError.new

        mock(@provider).push(@inner_unit)
        mock(@inner_unit).perform_rollback(cause)
        mock(@provider).clear(@inner_unit)

        @listener.on_rollback @outer_unit, cause
      end

      it 'ensures the inner unit is rolled back if the outer unit is rolled back' do
        cause = TestError.new

        mock(@provider).push(@inner_unit)
        mock(@inner_unit).perform_rollback(cause) {
          raise TestError
        }
        mock(@provider).clear(@inner_unit)

        expect {
          @listener.on_rollback @outer_unit, cause
        }.to raise_error(TestError)
      end

      it 'cleans up the inner unit when the outer unit is cleaned up' do
        mock(@inner_unit).perform_cleanup
        @listener.on_cleanup @outer_unit
      end
    end

    TestError = Class.new RuntimeError

  end
end
