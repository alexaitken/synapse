require 'test_helper'

module Synapse
  module Configuration

    class ContainerTest < Test::Unit::TestCase
      def setup
        @container = Container.new
      end

      def test_fetch
        definition = Object.new
        target = Object.new

        mock(definition).id.any_times do
          :test_service
        end
        mock(definition).resolve(@container) do
          target
        end

        @container.register definition
        resolved = @container.fetch :test_service

        assert_same target, resolved
      end

      def test_fetch_optional
        assert_raise ArgumentError do
          @container.fetch :derp_service
        end

        assert_nil @container.fetch :derp_service, true
      end

      def test_fetch_tagged
        resolved = @container.fetch_tagged :tag

        assert_equal [], resolved

        definition = Object.new
        target = Object.new

        mock(definition).id.any_times do
          :test_service
        end
        mock(definition).resolve(@container) do
          target
        end

        @container.register definition
        @container.tag_service :tag, :test_service

        resolved = @container.fetch_tagged :tag

        assert_equal [target], resolved
      end

      def test_register
        definition = Object.new
        mock(definition).id

        assert_raise ArgumentError do
          @container.register definition
        end
      end
    end

  end
end
