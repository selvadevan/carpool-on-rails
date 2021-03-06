require File.expand_path('../boot', __FILE__)
require 'rails/all'
require 'devise'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CarPool
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # https://hackhands.com/rails-nameerror-uninitialized-constant-class-solution/
    config.autoload_paths += %W(#{config.root}/lib)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_job.queue_adapter = :sucker_punch

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # config.serve_static_assets = true
    # doing ABOVE instead via gem 'rails_12factor', group: :production

    # config.quiet_assets = false;
    # If you need to supress output for other paths you can do so by specifying:
    # config.quiet_assets_paths << '/silent/'

    # Fine Tuning !!! Still not getting right-click icons for each option to show up in production, thought precompile would help..
    # https://coderwall.com/p/6bmygq/heroku-rails-bower
    # Explicitly register the extensions we are interested in compiling
    config.assets.precompile.push(Proc.new do |path|
      File.extname(path).in? [
        '.html', '.erb', '.haml',                 # Templates
        '.png',  '.gif', '.jpg', '.jpeg', '.svg', # Images
        '.eot',  '.otf', '.svc', '.woff', '.ttf', '.woff2' # Fonts
      ]
    end)
    # config.assets.precompile += %w( .svg .eot .woff .ttf )
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')

  end
end
