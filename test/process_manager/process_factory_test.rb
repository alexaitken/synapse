require 'test_helper'

module Synapse
  module ProcessManager
    class GenericProcessFactoryTest < Test::Unit::TestCase
      def test_create
        injector = Object.new

        mock(injector).inject_resources(is_a(Process))

        factory = GenericProcessFactory.new
        factory.resource_injector = injector

        process = factory.create Process

        assert process.is_a? Process
      end

      def test_supports
        factory = GenericProcessFactory.new

        assert factory.supports Process
        refute factory.supports StubProcessWithArguments
      end
    end

    class StubProcessWithArguments < Process
      def initialize(some_resource); end
    end
  end
end
