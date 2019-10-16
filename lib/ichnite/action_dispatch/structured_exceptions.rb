module Ichnite
  module ActionDispatch
    module StructuredExceptions
      def render_exception(_env, e)
        begin
          exception_name = e.class.name
          status = ::ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_name)
          if status == 500
            ::Ichnite.log('request_error',
              at: :error,
              error: exception_name,
              message: e.message[/\A.+$/].inspect
            )
          end
        rescue Exception => e2
          # never interfere with the regular exception handling
          ::Rails.logger.error(e2.inspect)
        end

        super
      end

      def log_error(*)
        # no-logging
      end
    end
  end
end
