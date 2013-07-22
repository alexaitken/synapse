require 'test_helper'

module Synapse
  class IdentifierLockManagerTest < Test::Unit::TestCase
    CountdownLatch = Contender::CountdownLatch

    should 'dispose locks when they are no longer in use' do
      manager = IdentifierLockManager.new

      identifier = SecureRandom.uuid
      manager.obtain_lock identifier
      manager.release_lock identifier

      assert_equal 0, manager.internal_locks.size
    end

    should 'not dispose locks when they are still in use' do
      manager = IdentifierLockManager.new

      identifier = SecureRandom.uuid

      refute manager.owned? identifier

      manager.obtain_lock identifier
      assert manager.owned? identifier

      manager.obtain_lock identifier
      assert manager.owned? identifier

      manager.release_lock identifier
      assert manager.owned? identifier

      manager.release_lock identifier
      refute manager.owned? identifier
    end

    should 'detect a deadlock between two threads' do
      manager = IdentifierLockManager.new

      start_latch = CountdownLatch.new 1
      latch = CountdownLatch.new 1
      deadlock = Atomic.new false

      lock_a = SecureRandom.uuid
      lock_b = SecureRandom.uuid

      start_lock_thread start_latch, latch, deadlock, manager, lock_a, manager, lock_b

      manager.obtain_lock lock_b

      start_latch.await
      latch.countdown

      begin
        manager.obtain_lock lock_a
        assert deadlock.get
      rescue DeadlockError
        # This is expected behavior
      end
    end

    should 'detect a deadlock between two threads across lock managers' do
      manager_a = IdentifierLockManager.new
      manager_b = IdentifierLockManager.new

      start_latch = CountdownLatch.new 1
      latch = CountdownLatch.new 1
      deadlock = Atomic.new false

      lock_a = SecureRandom.uuid
      lock_b = SecureRandom.uuid

      start_lock_thread start_latch, latch, deadlock, manager_a, lock_a, manager_b, lock_a

      manager_b.obtain_lock lock_a

      start_latch.await
      latch.countdown

      begin
        manager_a.obtain_lock lock_a
        assert deadlock.get
      rescue DeadlockError
        # This is expected behavior
      end
    end

    should 'detect a deadlock between three threads in a vector' do
      manager = IdentifierLockManager.new

      start_latch = CountdownLatch.new 3
      latch = CountdownLatch.new 1
      deadlock = Atomic.new false

      lock_a = SecureRandom.uuid
      lock_b = SecureRandom.uuid
      lock_c = SecureRandom.uuid
      lock_d = SecureRandom.uuid

      start_lock_thread start_latch, latch, deadlock, manager, lock_a, manager, lock_b
      start_lock_thread start_latch, latch, deadlock, manager, lock_b, manager, lock_c
      start_lock_thread start_latch, latch, deadlock, manager, lock_c, manager, lock_d

      manager.obtain_lock lock_d

      start_latch.await
      latch.countdown

      begin
        manager.obtain_lock lock_a
        assert deadlock.get
      rescue DeadlockError
        # This is expected behavior
      end
    end

  private

    def start_lock_thread(start_latch, latch, deadlock, manager_a, lock_a, manager_b, lock_b)
      Thread.new do
        manager_a.obtain_lock lock_a
        start_latch.countdown

        begin
          latch.await

          manager_b.obtain_lock lock_b
          manager_b.release_lock lock_b
        rescue DeadlockError
          deadlock.set true
        ensure
          manager_a.release_lock lock_a
        end
      end
    end
  end
end
