require 'vkontakte_api'
require 'dotenv/load'
require 'json'

# 1. Проверка окружения
if ENV['VK_ACCESS_TOKEN'].nil? || ENV['VK_GROUP_ID'].nil?
  puts "ОШИБКА: Проверь файл .env!"
  exit
end

# 2. Настройка API
VkontakteApi.configure do |config|
  config.adapter = :net_http
  config.api_version = '5.131'
end

# 3. Метод для создания клавиатуры (Две зеленые кнопки)
def main_keyboard
  {
    one_time: false,
    buttons: [
      [
        {
          action: {
            type: 'text',
            label: 'Игры',
            payload: { command: 'games' }.to_json
          },
          color: 'positive'
        },
        {
          action: {
            type: 'text',
            label: 'Помощь',
            payload: { command: 'help' }.to_json
          },
          color: 'positive'
        }
      ]
    ]
  }.to_json
end

# 4. Инициализация клиента
vk = VkontakteApi::Client.new(ENV['VK_ACCESS_TOKEN'])

puts "Подключаюсь к Long Poll..."

begin
  lp_settings = vk.groups.getLongPollServer(group_id: ENV['VK_GROUP_ID'], access_token: ENV['VK_ACCESS_TOKEN'])
  server = lp_settings['server']
  key    = lp_settings['key']
  ts     = lp_settings['ts']
rescue => e
  puts "Ошибка подключения: #{e.message}"
  exit
end

puts "Бот запущен в ветке develop... Текст помощи обновлен!"

# 5. Главный цикл
loop do
  begin
    connection = Faraday.new(url: server) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.response :json
    end

    response = connection.get('', { act: 'a_check', key: key, ts: ts, wait: 25 }).body

    if response['failed']
      lp_settings = vk.groups.getLongPollServer(group_id: ENV['VK_GROUP_ID'], access_token: ENV['VK_ACCESS_TOKEN'])
      ts = lp_settings['ts']
      key = lp_settings['key']
      next
    end

    ts = response['ts']
    updates = response['updates'] || []

    updates.each do |update|
      if update['type'] == 'message_new'
        message_data = update['object']['message']
        user_id = message_data['from_id']
        text    = message_data['text'].to_s.strip.downcase

        puts "Сообщение от #{user_id}: #{text}"

        reply = case text
                when 'привет', 'начать', 'start'
                  "Привет! Я готов к работе. Используй кнопки ниже!"
                when 'игры'
                  "Раздел игр в разработке. Скоро запустим первую!"
                when 'помощь'
                  "Я игровой бот на Ruby. У меня есть три режима игры, и я написан в учебных целях!"
                else
                  "Нажми на одну из зеленых кнопок ъ"
                end

        vk.messages.send(
          user_id: user_id,
          message: reply,
          keyboard: main_keyboard,
          random_id: rand(1..1_000_000),
          access_token: ENV['VK_ACCESS_TOKEN']
        )
      end
    end

  rescue Interrupt
    puts "\nБот остановлен."
    break
  rescue => e
    puts "Ошибка: #{e.message}"
    sleep 2
  end
end