module Games
  class Quiz
    QUESTIONS = [
      { q: "Какой язык программирования использует символ '#' для однострочных комментариев?", opts: ["Python", "C++", "Ruby", "JavaScript"], a: "python" },
      { q: "Как называется процесс поиска и исправления ошибок в коде?", opts: ["Компиляция", "Дебаггинг", "Рефакторинг", "Интерпретация"], a: "дебаггинг" },
      { q: "Что означает аббревиатура HTML?", opts: ["HyperText Markup Language", "High Tech Modern Language", "Hyperlink Tool Masonry", "Home Tool Markup Line"], a: "hypertext markup language" },
      { q: "Какая структура данных работает по принципу LIFO (Last In, First Out)?", opts: ["Очередь", "Стек", "Дерево", "Массив"], a: "стек" },
      { q: "Кто считается первым программистом в истории?", opts: ["Алан Тьюринг", "Билл Гейтс", "Ада Лавлейс", "Стив Джобс"], a: "ада лавлейс" },
      { q: "Какой протокол используется для защищенной передачи данных в вебе?", opts: ["HTTP", "FTP", "HTTPS", "SMTP"], a: "https" },
      { q: "Как в JavaScript объявить константу?", opts: ["var", "let", "const", "fixed"], a: "const" },
      { q: "Какая компания разработала язык Java?", opts: ["Microsoft", "Sun Microsystems", "Google", "Apple"], a: "sun microsystems" },
      { q: "Что такое SQL?", opts: ["Язык запросов к базам данных", "Протокол сети", "Библиотека для графики", "Тип процессора"], a: "язык запросов к базам данных" },
      { q: "Как называется репозиторий для хранения кода с системой контроля версий?", opts: ["Docker", "GitHub", "Nginx", "Visual Studio"], a: "github" }
    ].freeze

    MAX_QUESTIONS = 5

    def self.start(user_id, state_store)
      all_indices = (0...QUESTIONS.size).to_a.shuffle
      queue = all_indices.take(MAX_QUESTIONS)
      
      current_q_index = queue.shift
      q_data = QUESTIONS[current_q_index]

      state_store[user_id] = { 
        game: :quiz, 
        status: :playing, 
        correct_answer: q_data[:a], # Ответ на текущий (первый) вопрос
        score: 0,
        current_step: 1,
        queue: queue 
      }
      
      {
        text: "Начинаем викторину! Повторов не будет. 🧠\nВопрос 1 из #{MAX_QUESTIONS}:\n\n#{q_data[:q]}",
        options: q_data[:opts]
      }
    end

    def self.play(user_id, text, state, state_store)
      if state[:status] == :finished
        if text == 'да'
          return start(user_id, state_store)
        else
          state_store.delete(user_id)
          return { text: "До встречи! 🔙", finish: true }
        end
      end

      user_answer = text.strip.downcase
      # Сначала проверяем ответ на ТЕКУЩИЙ вопрос
      is_correct = (user_answer == state[:correct_answer])
      state[:score] += 1 if is_correct
      
      # Формируем фидбек (текст о том, прав пользователь или нет)
      feedback = is_correct ? "Верно! ✅" : "Мимо... ❌\nПравильный ответ: #{state[:correct_answer].capitalize}"

      # Проверка окончания раунда
      if state[:queue].empty?
        final_score = state[:score]
        rank = case final_score
               when 5 then "Senior Developer! ⭐⭐⭐"
               when 3..4 then "Middle Developer! ⭐⭐"
               when 1..2 then "Junior Developer! ⭐"
               else "Intern! 📚"
               end

        state[:status] = :finished
        return {
          text: "#{feedback}\n\n🏁 Викторина окончена!\nТвой результат: #{final_score} из #{MAX_QUESTIONS}.\nТвой статус: #{rank}\n\nСыграем еще раз?",
          ask_again: true
        }
      end

      # Только теперь берем из очереди СЛЕДУЮЩИЙ вопрос
      next_q_index = state[:queue].shift
      q_data = QUESTIONS[next_q_index]
      
      state[:current_step] += 1
      state[:correct_answer] = q_data[:a] # Обновляем правильный ответ для следующего хода
      
      {
        text: "#{feedback}\n\nВопрос #{state[:current_step]} из #{MAX_QUESTIONS}:\n\n#{q_data[:q]}",
        options: q_data[:opts]
      }
    end
  end
end