require 'synapse/command/command_bus'
require 'synapse/command/command_callback'
require 'synapse/command/command_filter'
require 'synapse/command/command_handler'
require 'synapse/command/dispatch_interceptor'
require 'synapse/command/errors'
require 'synapse/command/interceptor_chain'
require 'synapse/command/message'
require 'synapse/command/message_builder'
require 'synapse/command/rollback_policy'
require 'synapse/command/simple_command_bus'

require 'synapse/command/callback/void'

module Synapse
  module Command
    extend self

    # @yield [CommandMessageBuilder]
    # @return [CommandMessage]
    def build_message(&block)
      CommandMessage.build &block
    end
  end
end
