# spec/spec_helper.rb
require 'rspec'
require 'dotenv/load'
require_relative '../app'
require_relative '../lib/games/guess_number'
require_relative '../lib/games/rock_paper_scissors'
require_relative '../lib/games/quiz'

RSpec.configure do |config|
  # Очищаем глобальное состояние перед каждым тестом
  config.before(:each) do
    $user_states.clear if defined?($user_states)
  end
  
  # Красивые выводы в консоль
  config.color = true
  config.formatter = :documentation
end