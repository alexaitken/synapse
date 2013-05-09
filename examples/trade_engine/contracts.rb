module TradeEngine
  module DomainObject
    extend ActiveSupport::Concern
    include ActiveModel::Serialization
    include ActiveModel::Validations

    def initialize
      yield self if block_given?
    end

    def attributes
      instance_values
    end

    def attributes=(attributes)
      attributes.each do |key, value|
        instance_variable_set "@#{key}", value
      end
    end
  end
end
