require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RerPro
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.time_zone = 'Asia/Tokyo'
    
    # 以下のテストは少なくともフェーズ１では不要のようなので、余計なファイルを作らないよう設定。
    config.generators do |g|
      g.test_framework :rspec,
        view_specs: false, # ビュースペックは、「信頼性の高いビューのテストを作ることは非常に面倒」とのこと。
        helper_specs: false, # Rspecに慣れて、余力が出てきたらtrueにしてもよいとのこと。
        routing_specs: false # ルーティングは、テストが要らないくらいシンプルにすべし、とのこと。
    end
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
