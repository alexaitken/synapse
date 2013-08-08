require 'synapse/unit_of_work/current_unit'
require 'synapse/unit_of_work/transaction_manager'
require 'synapse/unit_of_work/unit'
require 'synapse/unit_of_work/unit_listener'
require 'synapse/unit_of_work/unit_listener_list'
require 'synapse/unit_of_work/unit_factory'

require 'synapse/unit_of_work/nestable_unit'
require 'synapse/unit_of_work/outer_commit_listener'

require 'synapse/unit_of_work/default_unit'

module Synapse
  module UnitOfWork
    # Returns the current unit of work for the calling thread
    #
    # @api public
    # @see CurrentUnit
    # @raise [InvalidStateError] If there is no active unit of work
    # @return [Unit]
    def self.current
      CurrentUnit.get
    end
  end
end
