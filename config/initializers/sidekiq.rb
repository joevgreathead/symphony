# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_SIDEKIQ_URL', 'redis://localhost:9736/0') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_SIDEKIQ_URL', 'redis://localhost:9736/0') }
end
