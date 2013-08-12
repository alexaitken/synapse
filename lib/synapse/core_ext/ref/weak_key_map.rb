require 'ref'

# TODO Remove this once my pull request is in the next release
module Ref
  class WeakKeyMap
    alias_method :get, :[]
    alias_method :put, :[]=

    # @return [Boolean]
    def empty?
      @references_to_keys_map.each do |_, ref|
        return false if ref.object
      end

      true
    end
  end
end
