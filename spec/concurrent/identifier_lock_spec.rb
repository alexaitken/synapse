require 'spec_helper'

module Synapse
  module Concurrent

    describe IdentifierLock do
      it 'disposes locks when they are no longer in use' do
        manager = IdentifierLock.new

        identifier = SecureRandom.uuid
        manager.obtain_lock identifier
        manager.internal_locks.size.should == 1

        manager.release_lock identifier
        manager.internal_locks.size.should == 0
      end

      it 'does not dispose locks when they are still in use' do
        manager = IdentifierLock.new

        identifier = SecureRandom.uuid

        manager.owned?(identifier).should be_false

        manager.obtain_lock identifier
        manager.owned?(identifier).should be_true

        manager.obtain_lock identifier
        manager.owned?(identifier).should be_true

        manager.release_lock identifier
        manager.owned?(identifier).should be_true

        manager.release_lock identifier
        manager.owned?(identifier).should be_false
      end

      it 'detects a deadlock between two threads' do
        pending 'This behavior is not always reliable on multi-threaded Ruby'

        manager = IdentifierLock.new

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
          deadlock.get
        rescue DeadlockError
          # This is expected behavior
        end
      end

      it 'detects a deadlock between two threads across lock managers' do
        pending 'This behavior is not always reliable on multi-threaded Ruby'

        manager_a = IdentifierLock.new
        manager_b = IdentifierLock.new

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
          deadlock.get.should be_true
        rescue DeadlockError
          # This is expected behavior
        end
      end

      it 'detects a deadlock between three threads in a vector' do
        pending 'This behavior is not always reliable on multi-threaded Ruby'

        manager = IdentifierLock.new

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
          deadlock.get.should be_true
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

      CountdownLatch = Contender::CountdownLatch
    end

  end
end
