require 'spec_helper'

module Synapse
  module Auditing

    describe AuditingDispatchInterceptor do
      it 'registers a unit of work listener for auditing' do
        rv = Object.new
        chain = Object.new
        command = Object.new
        unit = Object.new

        interceptor = AuditingDispatchInterceptor.new [], []

        mock(unit).register_listener(is_a(AuditingUnitOfWorkListener))
        mock(chain).proceed(command) do
          rv
        end

        interceptor.intercept(command, unit, chain).should be(rv)
      end
    end

  end
end
