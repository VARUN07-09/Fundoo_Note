require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module FundooNotess
  class Application < Rails::Application
    config.load_defaults 8.0
    # config.active_job.queue_adapter = :sidekiq

    config.autoload_lib(ignore: %w[assets tasks])

    # 🚀 Log a message instead of trying to start Redis automatically
    config.before_initialize do
      puts "⚠️  Make sure Redis is running before starting Rails."
    end
  end
end
 