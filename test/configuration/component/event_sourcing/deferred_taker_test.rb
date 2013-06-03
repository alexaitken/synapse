require 'test_helper'

module Synapse
  module Configuration
    class DeferredSnapshotTakerDefinitionBuilderTest < Test::Unit::TestCase

      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with sensible defaults' do
        @builder.factory :delegate_snapshot_taker do
          Object.new
        end

        @builder.deferred_snapshot_taker do
          use_snapshot_taker :delegate_snapshot_taker
        end

        taker = @container.resolve :snapshot_taker

        thread_pool = taker.thread_pool
        assert_equal 2, thread_pool.min
        assert_equal 2, thread_pool.max
      end

    end
  end
end
