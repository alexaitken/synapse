module Synapse
  # Provides a namespaced thread-local storage mechanism
  module Threaded
    extend self
    extend Forwardable

    # Returns the storage hash for the calling thread
    # @return [Hash]
    def current
      Thread.current[:synapse] ||= Hash.new
    end

    def_delegators :current, :[], :[]=
  end
end
