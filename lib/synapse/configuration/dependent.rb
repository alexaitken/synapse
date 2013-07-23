module Synapse
  module Configuration
    # Mixin for an object defines its dependencies so that they can be auto-injected by the
    # service container after it has been instantiated
    #
    # Note that this only supports setter injection
    module Dependent
      extend ActiveSupport::Concern

      included do
        # @return [Hash]
        class_attribute :dependencies, instance_accessor: false
        self.dependencies = Hash.new
      end

      module ClassMethods
        # @param [Symbol] service
        # @param [Object...] args
        # @return [undefined]
        def depends_on(service, *args)
          options = args.extract_options!

          attribute = options[:as] || service
          attr_accessor attribute

          dependencies.store service, attribute
        end
      end
    end # Dependent
  end # Configuration
end
