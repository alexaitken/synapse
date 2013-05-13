require 'active_support'
require 'active_support/core_ext'
require 'logging'
require 'set'

require 'synapse/version'

require 'synapse/common/errors'
require 'synapse/common/identifier'
require 'synapse/common/message'
require 'synapse/common/message_builder'

require 'synapse/common/concurrency/identifier_lock'
require 'synapse/common/concurrency/public_lock'

module Synapse
  extend ActiveSupport::Autoload

  autoload_at 'synapse/common/duplication' do
    autoload :DuplicationError
    autoload :DuplicationRecorder
  end

  eager_autoload do
    # Common components
    autoload :Command
    autoload :Domain
    autoload :EventBus
    autoload :Repository
    autoload :Serialization
    autoload :UnitOfWork, 'synapse/uow'
    autoload :Wiring
  end

  # Optional components
  autoload :Auditing
  autoload :Configuration
  autoload :EventSourcing
  autoload :EventStore
  autoload :Partitioning
  autoload :ProcessManager
  autoload :Upcasting

  # @return [Configuration::Container]
  mattr_accessor :container
  # @return [Configuration::ContainerBuilder]
  mattr_accessor :container_builder

  def self.build(&block)
    self.container ||= Configuration::Container.new
    self.container_builder ||= Configuration::ContainerBuilder.new self.container

    self.container_builder.instance_exec(&block)
  end
end
