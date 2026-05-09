# handlers/message_handler.rb
module MessageHandler
  def self.process(vk, user_id, text, state)
    if state
      process_game(vk, user_id, text, state)
    else
      process_command(vk, user_id, text)
    end
  end

  def self.process_game(vk, user_id, text, state)
    if text == 'закончить игру'
      $user_states.delete(user_id)
      send_msg(vk, user_id, text: "Игра прервана. 🔙", kb: main_kb)
    elsif state[:game] == :guess
      res = Games::GuessNumber.play(user_id, text, state, $user_states)
      send_msg(vk, user_id, res.merge(kb: res[:ask_again] ? yes_no_kb : (res[:finish] ? main_kb : game_kb)))
    elsif state[:game] == :rps
      res = Games::RockPaperScissors.play(user_id, text, state, $user_states)
      send_msg(vk, user_id, res.merge(kb: res[:ask_again] ? yes_no_kb : (res[:finish] ? main_kb : rps_kb)))
    elsif state[:game] == :quiz
      res = Games::Quiz.play(user_id, text, state, $user_states)
      kb = res[:ask_again] ? yes_no_kb : (res[:finish] ? main_kb : (res[:options] ? quiz_kb(res[:options]) : game_kb))
      send_msg(vk, user_id, res.merge(kb: kb))
    end
  end

  def self.process_command(vk, user_id, text)
    case text
    when 'привет', 'начать'
      send_msg(vk, user_id, text: "Привет! 👋 Выбирай режим игры:", kb: main_kb)
    when 'угадай число'
      res = Games::GuessNumber.start(user_id, $user_states)
      send_msg(vk, user_id, res.merge(kb: game_kb))
    when 'камень, ножницы...'
      res = Games::RockPaperScissors.start(user_id, $user_states)
      send_msg(vk, user_id, res.merge(kb: rps_kb))
    when 'викторина'
      res = Games::Quiz.start(user_id, $user_states)
      send_msg(vk, user_id, res.merge(kb: quiz_kb(res[:options])))
    else
      send_msg(vk, user_id, text: "Воспользуйся кнопками меню!", kb: main_kb)
    end
  end
end