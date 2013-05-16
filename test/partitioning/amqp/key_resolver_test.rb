require 'test_helper'
require 'partitioning/amqp/fixtures'

module Synapse
  module Partitioning
    module AMQP
      class ModuleRoutingKeyResolverTest < Test::Unit::TestCase
        def test_resolve
          message = Message.build do |builder|
            builder.payload = TradeEngine::Core::TestEvent.new
          end

          resolver = ModuleRoutingKeyResolver.new
          key = resolver.resolve_key message

          assert_equal 'trade_engine.core', key
        end
      end
    end # AMQP
  end # Partitioning
end
