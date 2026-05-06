module Games
  class RockPaperScissors
    SHAPES = {
      'камень' => { beats: 'ножницы', emoji: '🪨' },
      'ножницы' => { beats: 'бумага', emoji: '✂️' },
      'бумага' => { beats: 'камень', emoji: '📄' }
    }.freeze

    def self.start(user_id, state_store)
      state_store[user_id] = { game: :rps, status: :playing }
      {
        text: "Выбирай свою фигуру: Камень, Ножницы или Бумага? 👊✌️✋"
      }
    end

    def self.play(user_id, text, state, state_store)
      if state[:status] == :won_or_lost
        if text == 'да'
          return start(user_id, state_store)
        else
          state_store.delete(user_id)
          return { text: "Было весело! Возвращаемся в меню. 🔙", finish: true }
        end
      end

      user_choice = text.strip.downcase
      unless SHAPES.key?(user_choice)
        return { text: "Я не знаю такой фигуры... Выбирай кнопками: Камень, Ножницы или Бумага! 😊" }
      end

      bot_choice = SHAPES.keys.sample
      user_emoji = SHAPES[user_choice][:emoji]
      bot_emoji = SHAPES[bot_choice][:emoji]

      result_text = "Твой выбор: #{user_emoji}\nМой выбор: #{bot_emoji}\n\n"

      if user_choice == bot_choice
        result_text += "Ничья! 🤝 Попробуем еще раз?"
        return { text: result_text }
      elsif SHAPES[user_choice][:beats] == bot_choice
        result_text += "Ты победил! 🎉 Горжусь тобой."
      else
        result_text += "Я победил! 🤖 Не расстраивайся."
      end

      state[:status] = :won_or_lost
      { 
        text: "#{result_text}\n\nСыграем еще раз?", 
        ask_again: true 
      }
    end
  end
end