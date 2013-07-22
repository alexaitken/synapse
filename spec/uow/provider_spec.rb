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

        expect(@provider.started?).to be_true
        @provider.clear uow
        expect(@provider.started?).to be_false
      end

      it 'raises an exception if the given unit of work to be cleared does not match the current unit of work' do
        outer = UnitOfWork.new @provider
        inner = UnitOfWork.new @provider

        outer.start
        inner.start

        expect {
          @provider.clear outer
        }.to raise_error(ArgumentError)
      end

      it 'commits the current unit of work and clear it from the provider' do
        uow = UnitOfWork.new @provider
        uow.start

        @provider.commit

        expect(@provider.started?).to be_false
        expect(uow.started?).to be_false
      end

      it 'returns the current unit of work, if one is in the stack' do
        uow = UnitOfWork.new @provider

        expect {
          @provider.current
        }.to raise_error(RuntimeError)

        uow.start

        expect(@provider.current).to be(uow)
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

        expect(t1.value).to be_true
        expect(t2.value).to be_false
      end
    end

  end
end
