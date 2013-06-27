require 'test_helper'

require 'rails'
require 'synapse/railtie'

module Synapse
  module Rails
    class InjectionHelperTest < Test::Unit::TestCase

      def setup
        @controller_class = Class.new
        @controller = @controller_class.new
        mock(@controller_class).before_filter(:inject_dependencies)
        @controller_class.send :include, InjectionHelper
      end

      should 'inject dependencies from the Synapse container' do
        container_mock = stub(Synapse).container.mock!
        container_mock.inject_into(@controller)

        @controller.inject_dependencies
        @controller.inject_dependencies
      end

    end
  end
end
