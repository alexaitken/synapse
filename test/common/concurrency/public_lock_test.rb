require 'test_helper'

module Synapse
  class PublicLockTest < Test::Unit::TestCase
    def test_waiting
      @lock = PublicLock.new
      @lock.lock

      t1 = Thread.new do
        @lock.lock
      end

      t2 = Thread.new do
        @lock.lock
      end

      wait_until do
        @lock.waiting == [t1, t2]
      end
    end

    def test_lock_raises
      @lock = PublicLock.new
      @lock.lock

      assert_raise ThreadError do
        @lock.lock
      end
    end

    def test_lock_removes_waiting
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

    def test_synchronize
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

    def test_unlock_raises
      @lock = PublicLock.new

      assert_raise ThreadError do
        @lock.unlock
      end
    end

    def test_try_lock
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

    def test_try_lock_raises
      @lock = PublicLock.new
      @lock.try_lock

      assert_raise ThreadError do
        @lock.try_lock
      end
    end
  end
end
