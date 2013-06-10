module Synapse
  # Simple integration between the Synapse framework and Rails 3.2+
  class Railtie < Rails::Railtie
    # Set the name of the Railtie
    railtie_name :synapse

    # Controllers will get dependencies injected automatically
    initializer 'synapse.include_controller_mixins' do
      ActionController::Base.class_eval do
        include Synapse::Configuration::Dependent
        include Synapse::Rails::InjectionHelper
      end
    end
  end # Railtie
end

require 'synapse/rails/injection_helper'
