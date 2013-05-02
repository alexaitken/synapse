module Synapse
  module Command
    class ActiveModelValidationFilter < CommandFilter
      # @raise [ActiveModelValidationError] If command doesn't pass validation
      # @param [CommandMessage] command
      # @return [CommandMessage] The command to dispatch
      def filter(command)
        payload = command.payload

        if payload.respond_to? :valid?
          unless payload.valid?
            raise ActiveModelValidationError, payload.errors
          end
        end

        command
      end
    end

    # Raised when a command with ActiveModel doesn't pass validation
    class ActiveModelValidationError < CommandValidationError
      # @return [ActiveModel::Errors]
      attr_reader :errors

      # @param [ActiveModel::Errors] errors
      # @return [undefined]
      def initialize(errors)
        @errors = errors
      end
    end
  end
end
