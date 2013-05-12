require 'test_helper'

module Synapse
  class IdentifierLockTest < Test::Unit::TestCase
    def test_disposal
      lock = IdentifierLock.new
      identifier = 'some_id'

      lock.obtain_lock identifier
      lock.release_lock identifier

      identifiers = lock.instance_variable_get :@identifiers
      refute identifiers.has_key? identifier
    end

    def test_owned?
      lock = IdentifierLock.new
      identifier = 'some_id'

      refute lock.owned? identifier

      lock.obtain_lock identifier
      assert lock.owned? identifier

      lock.release_lock identifier
      refute lock.owned? identifier
    end

    def test_release_lock
      lock = IdentifierLock.new
      assert_raise ThreadError do
        lock.release_lock 'derp'
      end
    end
  end
end
