# spec/games/rock_paper_scissors_spec.rb
require 'spec_helper'

RSpec.describe Games::RockPaperScissors do
  let(:user_id) { 123456 }
  let(:state_store) { {} }
  
  describe '.start' do
    it 'запускает игру' do
      result = described_class.start(user_id, state_store)
      
      expect(state_store[user_id][:game]).to eq(:rps)
      expect(result[:text]).to include('Выбирай свою фигуру')
    end
  end
  
  describe '.play' do
    let(:state) { { game: :rps, status: :playing } }
    
    it 'принимает камень, ножницы, бумагу' do
      result = described_class.play(user_id, 'камень', state, state_store)
      expect(result[:text]).to include('Твой выбор')
    end
    
    it 'игнорирует регистр букв' do
      result = described_class.play(user_id, 'КАМЕНЬ', state, state_store)
      expect(result[:text]).to include('Твой выбор')
    end
    
    it 'отклоняет неизвестные фигуры' do
      result = described_class.play(user_id, 'динозавр', state, state_store)
      expect(result[:text]).to include('не знаю такой фигуры')
    end
    
    it 'объявляет победителя (камень побеждает ножницы)' do
      allow(Games::RockPaperScissors::SHAPES.keys).to receive(:sample).and_return('ножницы')
      result = described_class.play(user_id, 'камень', state, state_store)
      expect(result[:text]).to include('Ты победил!')
    end
    
    it 'обрабатывает ничью' do
      allow(Games::RockPaperScissors::SHAPES.keys).to receive(:sample).and_return('камень')
      result = described_class.play(user_id, 'камень', state, state_store)
      expect(result[:text]).to include('Ничья')
    end
  end
end