require 'ichnite/sidekiq/middleware'

Sidekiq.logger.level = Logger::WARN

Sidekiq.configure_server do |config|
  # Remove Sidekiqs default backtrace logging
  if !defined?(::Rails) || ::Rails.env.production?
    config.error_handlers.delete_if { |h| Sidekiq::ExceptionHandler::Logger === h }
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Ichnite::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Ichnite::ClientMiddleware
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Ichnite::ServerMiddleware
  end
end
