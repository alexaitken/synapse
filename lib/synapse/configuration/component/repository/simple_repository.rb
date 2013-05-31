module Synapse
  module Configuration
    # Definition builder used to create simple aggregate repositories
    #
    # @example The minimum possible effort to build a simple repository
    #   simple_repository :user_repository do
    #     use_aggregate_type User
    #   end
    class SimpleRepositoryDefinitionBuilder < LockingRepositoryDefinitionBuilder
      # @param [Class] aggregate_type
      # @return [undefined]
      def use_aggregate_type(aggregate_type)
        @aggregate_type = aggregate_type
      end

    protected

      # @return [undefined]
      def populate_defaults
        super

        use_factory do
          lock_manager = build_lock_manager

          repository = Repository::SimpleRepository.new lock_manager, @aggregate_type
          inject_base_dependencies repository
        end
      end
    end # SimpleRepositoryDefinitionBuilder
  end # Configuration
end
