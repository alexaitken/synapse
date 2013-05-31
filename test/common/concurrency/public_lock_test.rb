require 'test_helper'

module Synapse
  class PublicLockTest < Test::Unit::TestCase
    should 'raise an exception when a thread tries to obtain a lock twice' do
      @lock = PublicLock.new
      @lock.lock

      assert_raise ThreadError do
        @lock.lock
      end
    end

    should 'properly manage its list of waiting threads' do
      @lock = PublicLock.new
      @lock.lock

      t = Thread.new do
        @lock.lock
      end

      wait_until do
        @lock.waiting == [t]
      end

      t.kill

      wait_until do
        @lock.waiting == []
      end
    end

    should 'synchronize the execution of a block' do
      @lock = PublicLock.new

      refute @lock.owned?
      refute @lock.owned_by? Thread.current

      @lock.synchronize do
        assert @lock.owned?
        assert @lock.owned_by? Thread.current
      end

      refute @lock.owned?
      refute @lock.owned_by? Thread.current
    end

    should 'raise an exception when a thread releases a lock it does not own' do
      @lock = PublicLock.new

      assert_raise ThreadError do
        @lock.unlock
      end
    end

    should 'provide a non-blocking lock attempt' do
      @lock = PublicLock.new

      t = Thread.new do
        assert @lock.try_lock
        Thread.stop
        @lock.unlock
      end

      wait_until do
        @lock.owned_by? t
      end

      refute @lock.try_lock

      t.wakeup
    end

    should 'raise an exception when a thread tries to obtain a non-blocking lock twice' do
      @lock = PublicLock.new
      @lock.try_lock

      assert_raise ThreadError do
        @lock.try_lock
      end
    end
  end
end
