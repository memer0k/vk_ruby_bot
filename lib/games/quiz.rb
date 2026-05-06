module Games
  class Quiz
    # База из 10 вопросов по программированию
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

    # Количество вопросов в одном раунде
    MAX_QUESTIONS = 5

    def self.start(user_id, state_store)
      q_data = QUESTIONS.sample
      state_store[user_id] = { 
        game: :quiz, 
        status: :playing, 
        correct_answer: q_data[:a],
        score: 0,
        current_step: 1,
        last_q: q_data[:q]
      }
      
      {
        text: "Начинаем викторину! 🧠\nВопрос 1 из #{MAX_QUESTIONS}:\n\n#{q_data[:q]}",
        options: q_data[:opts]
      }
    end

    def self.play(user_id, text, state, state_store)
      # Если игрок уже закончил и выбирает Да/Нет
      if state[:status] == :finished
        if text == 'да'
          return start(user_id, state_store)
        else
          state_store.delete(user_id)
          return { text: "Надеюсь, было познавательно! Возвращаемся в меню. 🔙", finish: true }
        end
      end

      user_answer = text.strip.downcase
      is_correct = (user_answer == state[:correct_answer])
      
      state[:score] += 1 if is_correct
      
      # Проверка окончания раунда
      if state[:current_step] >= MAX_QUESTIONS
        final_score = state[:score]
        feedback = is_correct ? "Верно! ✅" : "Ошибка... ❌\nПравильный ответ был: #{state[:correct_answer].capitalize}"
        
        rank = case final_score
               when 5 then "Senior Developer! ⭐⭐⭐"
               when 3..4 then "Middle Developer! ⭐⭐"
               when 1..2 then "Junior Developer! ⭐"
               else "Intern (надо подучить)! 📚"
               end

        state[:status] = :finished
        return {
          text: "#{feedback}\n\n🏁 Викторина окончена!\nТвой результат: #{final_score} из #{MAX_QUESTIONS}.\nТвой статус: #{rank}\n\nСыграем еще раз?",
          ask_again: true
        }
      end

      # Переход к следующему вопросу
      state[:current_step] += 1
      # Выбираем вопрос, которого не было только что
      q_data = QUESTIONS.reject { |q| q[:q] == state[:last_q] }.sample
      state[:correct_answer] = q_data[:a]
      state[:last_q] = q_data[:q]
      
      feedback = is_correct ? "Верно! ✅" : "Мимо... ❌\nПравильный ответ был: #{state[:correct_answer].capitalize}"
      
      {
        text: "#{feedback}\n\nВопрос #{state[:current_step]} из #{MAX_QUESTIONS}:\n\n#{q_data[:q]}",
        options: q_data[:opts]
      }
    end
  end
end