require 'spec_helper'

module Synapse
  module UnitOfWork

    describe UnitOfWorkProvider do
      before do
        @provider = UnitOfWorkProvider.new
      end

      it 'clears the current unit of work if it matches the given unit of work' do
        uow = UnitOfWork.new @provider
        uow.start

        @provider.should be_started
        @provider.clear uow
        @provider.should_not be_started
      end

      it 'raises an exception if the given unit of work to be cleared does not match the current unit of work' do
        outer = UnitOfWork.new @provider
        inner = UnitOfWork.new @provider

        outer.start
        inner.start

        expect {
          @provider.clear outer
        }.to raise_error ArgumentError
      end

      it 'commits the current unit of work and clear it from the provider' do
        uow = UnitOfWork.new @provider
        uow.start

        @provider.commit

        @provider.should_not be_started
        uow.should_not be_started
      end

      it 'returns the current unit of work, if one is in the stack' do
        uow = UnitOfWork.new @provider

        expect {
          @provider.current
        }.to raise_error RuntimeError

        uow.start

        @provider.current.should be(uow)
      end

      it 'tracks unit of work stacks separately for each thread' do
        t1 = Thread.new {
          uow = UnitOfWork.new @provider
          uow.start

          @provider.started?
        }.join

        t2 = Thread.new {
          @provider.started?
        }.join

        t1.value.should be_true
        t2.value.should be_false
      end
    end

  end
end
