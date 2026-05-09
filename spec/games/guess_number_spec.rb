# spec/games/guess_number_spec.rb
require 'spec_helper'

RSpec.describe Games::GuessNumber do
  let(:user_id) { 123456 }
  let(:state_store) { {} }
  
  describe '.start' do
    it 'запускает игру с числом от 1 до 100' do
      result = described_class.start(user_id, state_store)
      
      expect(state_store[user_id][:game]).to eq(:guess)
      expect(state_store[user_id][:target]).to be_between(1, 100)
      expect(result[:text]).to include('Запускаю')
    end
  end
  
  describe '.play' do
    let(:state) { { game: :guess, target: 50, attempts: 0, status: :playing } }
    
    it 'говорит "Маловато" если число меньше' do
      result = described_class.play(user_id, '30', state, state_store)
      expect(result[:text]).to include('Маловато')
    end
    
    it 'говорит "Перебор" если число больше' do
      result = described_class.play(user_id, '70', state, state_store)
      expect(result[:text]).to include('Перебор')
    end
    
    it 'поздравляет с победой' do
      result = described_class.play(user_id, '50', state, state_store)
      expect(result[:text]).to include('ЕЕЕЙ!')
      expect(result[:ask_again]).to be true
    end
    
    it 'отклоняет нечисловой ввод' do
      result = described_class.play(user_id, 'abc', state, state_store)
      expect(result[:text]).to include('только числа')
    end
    
    it 'перезапускает игру после победы при ответе "да"' do
      state[:status] = :won
      result = described_class.play(user_id, 'да', state, state_store)
      expect(state_store[user_id][:status]).to eq(:playing)
    end
  end
end