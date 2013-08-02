module Synapse
  module EventBus
    # Container that stores the metadata for an event listener cluster
    #
    # This implementation provides two important characteristics, indifferent access and
    # thread-safe operations.
    #
    # @api public
    class ClusterMetadata
      # @return [undefined]
      def initialize
        @properties = ThreadSafe::Cache.new
      end

      # @api public
      # @param [Symbol] key
      # @return [undefined]
      def delete(key)
        @properties.delete(normalize_key(key))
      end

      # @api public
      # @param [Symbol] key
      # @return [Object]
      def get(key)
        @properties.get(normalize_key(key))
      end

      # @api public
      # @param [Symbol] key
      # @return [Boolean]
      def key?(key)
        @properties.key?(normalize_key(key))
      end

      alias_method :has_key?, :key?

      # @api public
      # @param [Symbol] key
      # @param [Object] value
      # @return [undefined]
      def set(key, value)
        @properties.put(normalize_key(key), value)
      end

      # @api public
      # @return [Hash]
      def to_hash
        hash = Hash.new
        @properties.each_pair do |key, value|
          hash.put key, value
        end

        hash
      end

      private

      # @param [Object] key
      # @return [Symbol]
      def normalize_key(key)
        key.to_sym
      end
    end # ClusterMetadata
  end # EventBus
end
