require 'test_helper'

module Synapse
  module Command

    class InterceptorChainTest < Test::Unit::TestCase
      should 'allow interceptors to control the flow of dispatch' do
        unit = Object.new
        interceptor = Object.new
        interceptors = Array.new << interceptor
        handler = Object.new

        command = Object.new

        chain = InterceptorChain.new unit, interceptors, handler

        mock(interceptor).intercept(command, unit, chain).ordered
        mock(handler).handle(command, unit).ordered

        chain.proceed command
        chain.proceed command
      end
    end

  end
end
