require 'test_helper'

module Synapse
  module UnitOfWork
    class UnitOfWorkProviderTest < Test::Unit::TestCase
      def setup
        @provider = UnitOfWorkProvider.new
      end

      should 'clear the current unit of work if it matches the given unit of work' do
        uow = UnitOfWork.new @provider
        uow.start

        assert @provider.started?
        @provider.clear uow
        refute @provider.started?
      end

      should 'raise an exception if the given unit of work to be cleared does not match the current unit of work' do
        outer = UnitOfWork.new @provider
        inner = UnitOfWork.new @provider

        outer.start
        inner.start

        assert_raises ArgumentError do
          @provider.clear outer
        end
      end

      should 'commit the current unit of work and clear it from the provider' do
        uow = UnitOfWork.new @provider
        uow.start

        @provider.commit

        refute @provider.started?
        refute uow.started?
      end

      should 'return the current unit of work, if one is in the stack' do
        uow = UnitOfWork.new @provider

        assert_raises RuntimeError do
          @provider.current
        end

        uow.start

        assert_same uow, @provider.current
      end

      should 'keep unit of work stacks separate for each thread' do
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
