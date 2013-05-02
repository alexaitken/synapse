require 'test_helper'
require 'active_model'

module Synapse
  module Command

    class ActiveModelValidationFilterTest < Test::Unit::TestCase
      def test_filter
        message = CommandMessage.build do |m|
          m.payload = CreatePersonCommand.new 'River'
        end

        filter = ActiveModelValidationFilter.new
        filter.filter message
      end

      def test_filter_fails
        message = CommandMessage.build do |m|
          m.payload = CreatePersonCommand.new nil
        end

        filter = ActiveModelValidationFilter.new
        assert_raise ActiveModelValidationError do
          filter.filter message
        end
      end
    end

    class CreatePersonCommand
      include ActiveModel::Validations

      attr_reader :name

      validates :name, :presence => true

      def initialize(name)
        @name = name
      end
    end

  end
end
