require 'test_helper'

module Synapse
  module ProcessManager
    class GenericProcessFactoryTest < Test::Unit::TestCase
      def test_create
        injector = Object.new

        mock(injector).inject_resources(is_a(StubProcess))

        factory = GenericProcessFactory.new
        factory.resource_injector = injector

        process = factory.create StubProcess

        assert process.is_a? StubProcess
      end

      def test_supports
        factory = GenericProcessFactory.new

        assert factory.supports StubProcess
        refute factory.supports StubProcessWithArguments
      end
    end

    class StubProcess < Process; end
    class StubProcessWithArguments < Process
      def initialize(some_resource); end
    end
  end
end
