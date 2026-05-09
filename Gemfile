source 'https://rubygems.org'

gem 'sinatra'
gem 'thin' # Более быстрый сервер для Sinatra
gem 'json'
gem 'dotenv' # Чтобы безопасно хранить токен
gem 'vkontakte_api' # Для работы с VK API
gem 'faraday' # Для HTTP запросов

gem "rackup", "~> 2.3"
gem "puma", "~> 8.0"

group :development, :test do
  gem 'rspec' # Для написания тестов
end

group :test do
  gem 'webmock' # Для мокирования HTTP запросов в тестах (опционально)
end