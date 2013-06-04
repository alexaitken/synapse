module Synapse
  class Executor
    # @return [undefined]
    def execute(&block); end
  end

  class DirectExecutor < Executor
    # @return [undefined]
    def execute(&block)
      block.call
    end
  end
end
