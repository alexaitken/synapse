require 'ref'

# TODO Remove this once my pull request is in the next release
module Ref
  class WeakKeyMap
    alias_method :get, :[]
    alias_method :put, :[]=
  end
end
