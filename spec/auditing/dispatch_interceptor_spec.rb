require 'spec_helper'

module Synapse
  module Auditing

    describe AuditingDispatchInterceptor do
      it 'registers a unit of work listener for auditing' do
        result = Object.new
        chain = Object.new
        command = Object.new
        unit = Object.new

        interceptor = AuditingDispatchInterceptor.new

        mock(unit).register_listener(is_a(AuditingUnitListener))
        mock(chain).proceed(command) do
          result
        end

        interceptor.intercept(command, unit, chain).should be(result)
      end
    end

  end
end
