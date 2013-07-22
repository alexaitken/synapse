require 'test_helper'
require 'active_model'

module Synapse
  module Command

    class ActiveModelValidationFilterTest < Test::Unit::TestCase
      should 'continue if payload of a command message is valid' do
        message = CommandMessage.build do |m|
          m.payload = CreatePersonCommand.new 'River Tam'
        end

        filter = ActiveModelValidationFilter.new
        assert_same message, filter.filter(message)
      end

      should 'raise an exception if payload of a command message is invalid' do
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
