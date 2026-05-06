require 'vkontakte_api'
require 'dotenv/load'

# 1. Проверка окружения
if ENV['VK_ACCESS_TOKEN'].nil? || ENV['VK_GROUP_ID'].nil?
  puts "ОШИБКА: Проверь файл .env! Не найден токен или ID группы."
  exit
end

# 2. Настройка API
VkontakteApi.configure do |config|
  config.adapter = :net_http
  config.api_version = '5.131'
end

# 3. Инициализация клиента
vk = VkontakteApi::Client.new(ENV['VK_ACCESS_TOKEN'])

puts "Подключаюсь к Long Poll..."

# 4. Получаем данные для подключения (используем ['key'], чтобы избежать ошибок Ruby)
begin
  lp_settings = vk.groups.getLongPollServer(group_id: ENV['VK_GROUP_ID'], access_token: ENV['VK_ACCESS_TOKEN'])
  server = lp_settings['server']
  key    = lp_settings['key']
  ts     = lp_settings['ts']
rescue => e
  puts "Ошибка при получении настроек Long Poll: #{e.message}"
  exit
end

puts "Бот запущен... Жду сообщений в ВК!"

# 5. Главный цикл опроса сервера
loop do
  begin
    # Делаем запрос к Long Poll серверу
    connection = Faraday.new(url: server) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.response :json
    end

    response = connection.get('', {
      act: 'a_check',
      key: key,
      ts:  ts,
      wait: 25
    }).body

    # Если сессия устарела (failed), обновляем ts и key
    if response['failed']
      puts "Обновляю сессию Long Poll..."
      lp_settings = vk.groups.getLongPollServer(group_id: ENV['VK_GROUP_ID'], access_token: ENV['VK_ACCESS_TOKEN'])
      ts = lp_settings['ts']
      key = lp_settings['key']
      next
    end

    # Обновляем временную метку
    ts = response['ts']
    updates = response['updates'] || []

    # 6. Обработка событий
    updates.each do |update|
      if update['type'] == 'message_new'
        # В версии 5.131 данные лежат в ['object']['message']
        message_data = update['object']['message']
        user_id = message_data['from_id']
        text    = message_data['text'].to_s.downcase

        puts "Пришло сообщение: '#{text}' от ID: #{user_id}"

        # Простая логика ответов
        reply = case text
                when 'привет', 'начать'
                  "Привет! Я твой игровой бот. Напиши 'игры', чтобы посмотреть список."
                when 'игры'
                  "Сейчас доступны:\n1. Угадай число (скоро)\n2. Викторина (скоро)\n\nНапиши 'привет', если потерялся."
                else
                  "Я тебя не понял, но очень старался! Напиши 'привет' ъ"
                end

        # Отправляем ответ
        vk.messages.send(
          user_id: user_id,
          message: reply,
          random_id: rand(1..1_000_000),
          access_token: ENV['VK_ACCESS_TOKEN']
        )
      end
    end

  rescue Interrupt
    puts "\nБот выключен пользователем."
    break
  rescue => e
    puts "Произошла ошибка: #{e.message}. Переподключаюсь через 2 секунды..."
    sleep 2
  end
end