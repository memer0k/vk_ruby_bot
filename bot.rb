# bot.rb
require_relative 'app'
require_relative 'handlers/message_handler'
require 'faraday'

puts "Бот подключается к ВК..."
begin
  lp = $vk.groups.getLongPollServer(group_id: ENV['VK_GROUP_ID'])
  server, key, ts = lp['server'], lp['key'], lp['ts']
rescue => e
  puts "Ошибка API: #{e.message}"
  exit
end

puts "Бот запущен! 🚀"

loop do
  begin
    connection = Faraday.new(url: server) { |f| f.adapter Faraday.default_adapter; f.response :json }
    response = connection.get('', { act: 'a_check', key: key, ts: ts, wait: 25 }).body
    ts = response['ts'] if response['ts']

    (response['updates'] || []).each do |update|
      next unless update['type'] == 'message_new'
      msg = update['object']['message']
      user_id = msg['from_id']
      text = msg['text'].to_s.strip.downcase
      state = $user_states[user_id]

      MessageHandler.process($vk, user_id, text, state)
    end
  rescue => e
    puts "Ошибка: #{e.message}"
    sleep 2
  end
end