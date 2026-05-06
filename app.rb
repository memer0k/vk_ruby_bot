require 'vkontakte_api'
require 'dotenv/load'
require 'json'
require_relative 'lib/games/guess_number'
require_relative 'lib/games/rock_paper_scissors'

VkontakteApi.configure do |config|
  config.adapter = :net_http
  config.api_version = '5.131'
end

vk = VkontakteApi::Client.new(ENV['VK_ACCESS_TOKEN'])
$user_states = {}

# --- КЛАВИАТУРЫ ---

def main_kb
  {
    one_time: false,
    buttons: [
      [
        { action: { type: 'text', label: 'Угадай число' }, color: 'positive' },
        { action: { type: 'text', label: 'КНБ' }, color: 'positive' }
      ],
      [{ action: { type: 'text', label: 'Помощь' }, color: 'secondary' }]
    ]
  }.to_json
end

def game_kb
  {
    one_time: false,
    buttons: [[{ action: { type: 'text', label: 'Закончить игру' }, color: 'negative' }]]
  }.to_json
end

def rps_kb
  {
    one_time: false,
    buttons: [
      [
        { action: { type: 'text', label: 'Камень' }, color: 'primary' },
        { action: { type: 'text', label: 'Ножницы' }, color: 'primary' },
        { action: { type: 'text', label: 'Бумага' }, color: 'primary' }
      ],
      [{ action: { type: 'text', label: 'Закончить игру' }, color: 'negative' }]
    ]
  }.to_json
end

def yes_no_kb
  {
    one_time: false,
    buttons: [[
      { action: { type: 'text', label: 'Да' }, color: 'positive' },
      { action: { type: 'text', label: 'Нет' }, color: 'negative' }
    ]]
  }.to_json
end

# --- ОТПРАВКА ---

def send_msg(vk, user_id, params)
  vk.messages.send(
    user_id: user_id,
    message: params[:text],
    keyboard: params[:kb],
    random_id: rand(1..2_147_483_647),
    access_token: ENV['VK_ACCESS_TOKEN']
  )
end

# --- LONG POLL ---

puts "Подключаюсь к ВК..."
begin
  lp = vk.groups.getLongPollServer(group_id: ENV['VK_GROUP_ID'])
  server, key, ts = lp['server'], lp['key'], lp['ts']
rescue => e
  puts "Ошибка подключения: #{e.message}"; exit
end

puts "Бот онлайн! 🚀"

loop do
  begin
    connection = Faraday.new(url: server) { |f| f.adapter Faraday.default_adapter; f.response :json }
    response = connection.get('', { act: 'a_check', key: key, ts: ts, wait: 25 }).body

    if response['failed']
      lp = vk.groups.getLongPollServer(group_id: ENV['VK_GROUP_ID'])
      ts, key = lp['ts'], lp['key']; next
    end

    ts = response['ts']
    (response['updates'] || []).each do |update|
      next unless update['type'] == 'message_new'
      
      msg = update['object']['message']
      user_id = msg['from_id']
      text = msg['text'].to_s.strip.downcase
      state = $user_states[user_id]

      if state
        if text == 'закончить игру'
          $user_states.delete(user_id)
          send_msg(vk, user_id, text: "Игра окончена. Возвращаемся в меню! 🔙", kb: main_kb)
        
        elsif state[:game] == :guess
          res = Games::GuessNumber.play(user_id, text, state, $user_states)
          res[:kb] = res[:ask_again] ? yes_no_kb : (res[:finish] ? main_kb : game_kb)
          send_msg(vk, user_id, res)
        
        elsif state[:game] == :rps
          res = Games::RockPaperScissors.play(user_id, text, state, $user_states)
          res[:kb] = res[:ask_again] ? yes_no_kb : (res[:finish] ? main_kb : rps_kb)
          send_msg(vk, user_id, res)
        end

      else
        case text
        when 'привет', 'начать'
          send_msg(vk, user_id, text: "Привет! 👋 Во что хочешь поиграть?", kb: main_kb)
        when 'угадай число'
          res = Games::GuessNumber.start(user_id, $user_states)
          send_msg(vk, user_id, res.merge(kb: game_kb))
        when 'кнб'
          res = Games::RockPaperScissors.start(user_id, $user_states)
          send_msg(vk, user_id, res.merge(kb: rps_kb))
        when 'помощь'
          send_msg(vk, user_id, text: "Я игровой бот на Ruby. Выбирай игру кнопками ниже! 🤓", kb: main_kb)
        else
          send_msg(vk, user_id, text: "Нажимай на кнопки в меню! ъ", kb: main_kb)
        end
      end
    end
  rescue Interrupt then break
  rescue => e
    puts "Ошибка цикла: #{e.message}"
    sleep 2
  end
end