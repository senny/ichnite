require 'ichnite/action_dispatch/structured_exceptions'

module Ichnite
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'ichnite_rails.setup' do |app|
        Ichnite.default_logger = Ichnite::Logger.new(::Rails.logger)

        ActiveSupport.on_load :action_controller do
          if defined?(::ActionDispatch::DebugExceptions)
            ::ActionDispatch::DebugExceptions.prepend Ichnite::ActionDispatch::StructuredExceptions
          elsif defined?(::ActionDispatch::ShowExceptions)
            ::ActionDispatch::ShowExceptions.prepend Ichnite::ActionDispatch::StructuredExceptions
          end
        end

        if !::Rails.env.test? && !::Rails.env.development?
          require 'active_support/tagged_logging'
          require 'ichnite/active_support/disable_tagged_logging_patch'
        end
      end
    end
  end
end
