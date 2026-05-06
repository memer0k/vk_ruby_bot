module Games
  class GuessNumber
    def self.start(user_id, state_store)
      state_store[user_id] = { game: :guess, target: rand(1..100), attempts: 0 }
      {
        text: "Запускаю 'Угадай число'! 🎲\nЯ загадал число от 1 до 100. Попробуй отгадать! 🤔"
      }
    end

    def self.play(user_id, text, state, state_store)
      unless text =~ /^\d+$/
        return { text: "Присылай только числа или нажми 'Закончить игру' 🙃" }
      end

      guess = text.to_i
      state[:attempts] += 1

      if guess < state[:target]
        { text: "Маловато! 👆 Моё число больше. (Попытка: #{state[:attempts]})" }
      elsif guess > state[:target]
        { text: "Перебор! 👇 Моё число меньше. (Попытка: #{state[:attempts]})" }
      else
        attempts = state[:attempts]
        state_store.delete(user_id)
        { 
          text: "ЕЕЕЙ! 🎉 Ты угадал! Это было число #{state[:target]}.\nПобеда за #{attempts} попыток! Сыграем еще? 😎", 
          finish: true 
        }
      end
    end
  end
end