require 'test_helper'

module Synapse
  class IdentifierLockTest < Test::Unit::TestCase
    should 'indicate whether the current thread holds a lock' do
      lock = IdentifierLock.new
      identifier = 'some_id'

      refute lock.owned? identifier

      lock.obtain_lock identifier
      assert lock.owned? identifier

      lock.release_lock identifier
      refute lock.owned? identifier
    end

    should 'raise an exception when a thread releases a lock it does not own' do
      lock = IdentifierLock.new
      assert_raise ThreadError do
        lock.release_lock 'derp'
      end
    end
  end
end
