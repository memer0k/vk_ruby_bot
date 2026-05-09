# spec/spec_helper.rb
require 'rspec'
require 'dotenv/load'

# Подключаем только необходимые файлы
require_relative '../app'
require_relative '../lib/games/guess_number'
require_relative '../lib/games/rock_paper_scissors'
require_relative '../lib/games/quiz'

# НЕ подключаем bot.rb и message_handler.rb (для изоляции тестов)

RSpec.configure do |config|
  config.before(:each) do
    $user_states.clear if defined?($user_states)
  end
  
  config.color = true
  config.formatter = :documentation
end