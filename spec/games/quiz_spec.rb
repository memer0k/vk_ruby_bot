# spec/games/quiz_spec.rb
require 'spec_helper'

RSpec.describe Games::Quiz do
  let(:user_id) { 123456 }
  let(:state_store) { {} }
  
  describe '.start' do
    it 'запускает викторину с первым вопросом' do
      result = described_class.start(user_id, state_store)
      
      expect(state_store[user_id][:game]).to eq(:quiz)
      expect(state_store[user_id][:score]).to eq(0)
      expect(result[:text]).to include('Начинаем викторину')
      expect(result[:options]).to be_an(Array)
    end
  end
  
  describe '.play' do
    let(:state) do
      {
        game: :quiz,
        status: :playing,
        correct_answer: 'ruby',
        score: 0,
        current_step: 1,
        queue: [1, 2, 3]
      }
    end
    
    it 'засчитывает правильный ответ' do
      result = described_class.play(user_id, 'ruby', state, state_store)
      expect(state[:score]).to eq(1)
      expect(result[:text]).to include('Верно!')
    end
    
    it 'не засчитывает неправильный ответ' do
      result = described_class.play(user_id, 'python', state, state_store)
      expect(state[:score]).to eq(0)
      expect(result[:text]).to include('Мимо...')
    end
    
    it 'не чувствителен к регистру' do
      result = described_class.play(user_id, 'RUBY', state, state_store)
      expect(state[:score]).to eq(1)
    end
    
    it 'завершает викторину после 5 вопросов' do
      state[:queue] = []
      state[:current_step] = 5
      result = described_class.play(user_id, 'ruby', state, state_store)
      
      expect(result[:text]).to include('Викторина окончена!')
      expect(result[:ask_again]).to be true
    end
    
    it 'перезапускает викторину при ответе "да" после завершения' do
      state[:status] = :finished
      result = described_class.play(user_id, 'да', state, state_store)
      
      expect(state_store[user_id][:status]).to eq(:playing)
      expect(result[:text]).to include('Начинаем викторину')
    end
  end
end