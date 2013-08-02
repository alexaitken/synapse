require 'thread_safe'

# TODO Remove when pull request is accepted
module ThreadSafe
  class Cache
    alias_method :get, :[]
    alias_method :put, :[]=
  end
end

class Array
  alias_method :get, :[]
end

class Hash
  alias_method :get, :[]
end
