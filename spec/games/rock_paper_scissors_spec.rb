# spec/games/rock_paper_scissors_spec.rb
require_relative '../spec_helper'

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
      allow_any_instance_of(Array).to receive(:sample).and_return('ножницы')
      result = described_class.play(user_id, 'камень', state, state_store)
      expect(result[:text]).to include('Ты победил!')
    end
    
    it 'обрабатывает ничью' do
      allow_any_instance_of(Array).to receive(:sample).and_return('камень')
      result = described_class.play(user_id, 'камень', state, state_store)
      expect(result[:text]).to include('Ничья')
    end
    
    it 'правильно определяет победу бота' do
      allow_any_instance_of(Array).to receive(:sample).and_return('бумага')
      result = described_class.play(user_id, 'камень', state, state_store)
      expect(result[:text]).to include('Я победил!')
    end
    
    it 'перезапускает игру после раунда при ответе "да"' do
      state[:status] = :won_or_lost
      result = described_class.play(user_id, 'да', state, state_store)
      expect(state_store[user_id][:status]).to eq(:playing)
      expect(result[:text]).to include('Выбирай свою фигуру')
    end
    
    it 'завершает игру при ответе "нет" после раунда' do
      state[:status] = :won_or_lost
      result = described_class.play(user_id, 'нет', state, state_store)
      expect(state_store[user_id]).to be_nil
      expect(result[:text]).to include('Возвращаемся в меню')
      expect(result[:finish]).to be true
    end
  end
end