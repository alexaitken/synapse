require 'spec_helper'
require 'active_model'

module Synapse
  module Command

    describe ActiveModelValidationFilter do
      it 'does nothing if payload of a command message is valid' do
        message = CommandMessage.build do |m|
          m.payload = CreatePersonCommand.new 'River Tam'
        end

        filter = ActiveModelValidationFilter.new
        filter.filter(message).should be(message)
      end

      it 'raises an exception if payload of a command message is invalid' do
        message = CommandMessage.build do |m|
          m.payload = CreatePersonCommand.new nil
        end

        filter = ActiveModelValidationFilter.new
        expect {
          filter.filter message
        }.to raise_error ActiveModelValidationError
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
