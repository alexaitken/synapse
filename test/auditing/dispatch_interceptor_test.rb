require 'test_helper'

module Synapse
  module Auditing

    class AuditingDispatchInterceptorTest < Test::Unit::TestCase
      def test_intercept
        return_value = Object.new
        chain = Object.new
        command = Object.new
        unit = Object.new

        interceptor = AuditingDispatchInterceptor.new

        mock(unit).register_listener(is_a(AuditingUnitOfWorkListener))
        mock(chain).proceed(command) do
          return_value
        end

        assert_equal return_value, interceptor.intercept(command, unit, chain)
      end
    end

  end
end
