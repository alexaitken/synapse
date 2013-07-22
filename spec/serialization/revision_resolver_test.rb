require 'test_helper'

module Synapse
  module Serialization
    
    class FixedRevisionResolverTest < Test::Unit::TestCase
      should 'return a fixed revision' do
        resolver = FixedRevisionResolver.new 1
        assert_equal '1', resolver.revision_of(Array)
      end
    end
    
  end
end
