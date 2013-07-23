module Synapse
  # Module that provides simple access to the logging mechanism
  module Loggable
    # @return [Logging::Logger]
    def logger
      Logging.logger[self.class]
    end

    private :logger
  end
end
