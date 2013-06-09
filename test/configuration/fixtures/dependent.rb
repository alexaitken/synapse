module Synapse
  module Configuration
    class ExampleDependent
      include Dependent

      depends_on :service_a
      depends_on :service_b, :as => :some_service
    end
  end
end
