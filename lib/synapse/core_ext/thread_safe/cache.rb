require 'thread_safe'

# TODO Remove this once my pull request is in the next release
module ThreadSafe
  class Cache
    alias_method :get, :[]
    alias_method :put, :[]=
  end
end
