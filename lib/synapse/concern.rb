module Synapse
  module Concern
    # @param [Module] base
    # @return [undefined]
    def self.extended(base)
      base.instance_variable_set :@_dependencies, []
    end

    # @param [Module] base
    # @return [Boolean]
    def append_features(base)
      if base.instance_variable_defined? :@_dependencies
        base.instance_variable_get(:@_dependencies) << self
        return false
      else
        return false if base < self
        @_dependencies.each { |dep| base.send :include, dep }
        super
        base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
        base.class_eval(&@_included_block) if instance_variable_defined?(:@_included_block)
      end
    end

    # @yield
    # @param [Module] base
    # @return [undefined]
    def included(base = nil, &block)
      if base.nil?
        @_included_block = block
      else
        super
      end
    end
  end # Concern
end
