require 'test_helper'

module Synapse
  module UnitOfWork
    class OuterCommitUnitOfWorkListenerTest < Test::Unit::TestCase
      def setup
        @provider = Object.new
        @outer_unit = Object.new
        @inner_unit = Object.new
        @listener = OuterCommitUnitOfWorkListener.new @inner_unit, @provider
      end

      should 'commit the inner unit if the outer unit is committed' do
        mock(@inner_unit).perform_inner_commit
        @listener.after_commit @outer_unit
      end

      should 'rollback the inner unit if the outer unit is rolled back' do
        cause = TestError.new

        mock(@provider).push(@inner_unit)
        mock(@inner_unit).perform_rollback(cause)
        mock(@provider).clear(@inner_unit)

        @listener.on_rollback @outer_unit, cause
      end

      should 'ensure the inner unit is rolled back if the outer unit is rolled back' do
        cause = TestError.new

        mock(@provider).push(@inner_unit)
        mock(@inner_unit).perform_rollback(cause) {
          raise TestError
        }
        mock(@provider).clear(@inner_unit)

        assert_raises TestError do
          @listener.on_rollback @outer_unit, cause
        end
      end

      should 'cleanup the inner unit if the outer unit is cleaned up' do
        mock(@inner_unit).perform_cleanup
        @listener.on_cleanup @outer_unit
      end
    end

    class TestError < StandardError; end
  end
end
