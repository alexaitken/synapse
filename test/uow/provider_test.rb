require 'test_helper'

module Synapse
  module UnitOfWork
    class UnitOfWorkProviderTest < Test::Unit::TestCase
      def setup
        @provider = UnitOfWorkProvider.new
      end

      def test_clear
        uow = UnitOfWork.new @provider
        uow.start

        assert @provider.started?
        @provider.clear uow
        refute @provider.started?
      end

      def test_clear_raises_mismatch
        outer = UnitOfWork.new @provider
        inner = UnitOfWork.new @provider

        outer.start
        inner.start

        assert_raises ArgumentError do
          @provider.clear outer
        end
      end

      def test_commit
        uow = UnitOfWork.new @provider
        uow.start

        @provider.commit

        refute @provider.started?
        refute uow.started?
      end

      def test_current
        uow = UnitOfWork.new @provider

        assert_raises RuntimeError do
          @provider.current
        end

        uow.start

        assert_same uow, @provider.current
      end

      def test_threading
        t1 = Thread.new {
          uow = UnitOfWork.new @provider
          uow.start

          @provider.started?
        }.join

        t2 = Thread.new {
          @provider.started?
        }.join

        assert t1.value
        refute t2.value
      end
    end
  end
end
