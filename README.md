# 🕹️ VK GameHub Bot 🤖

[![Ruby Version](https://img.shields.io/badge/ruby-v3.0+-red.svg?logo=ruby)](https://www.ruby-lang.org/)
[![VK Api Version](https://img.shields.io/badge/VK%20API-v5.131-blue.svg?logo=vk)](https://vk.com/dev/manuals)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

> **Многофункциональный игровой бот для ВКонтакте**, написанный на языке Ruby. Бот умеет развлекать пользователей тремя классическими играми в удобном интерфейсе с кнопками.

---

## 🎮 Доступные игры

1.  **🎲 Угадай число** — Бот загадывает число от 1 до 100, а игрок пытается его отгадать, получая подсказки "больше" или "меньше".
2.  **👊✌️✋ Камень, Ножницы, Бумага** — Классическая битва с алгоритмом на удачу через удобные кнопки.
3.  **🧠 IT-Викторина** — Испытание из 5 случайных вопросов по программированию. В конце выдает ранг (от Junior до Senior)!

---

## 🛠️ Технологический стек

Проект разработан с использованием современных и надежных инструментов:

| Технология | Логотип | Описание |
| :--- | :---: | :--- |
| **Ruby** | <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/ruby/ruby-original.svg" alt="ruby" width="25" height="25"/> | **Язык программирования:** Основной язык проекта. Чистый, элегантный и объектно-ориентированный. |
| **VK API (vkontakte_api)** | <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/twitter/twitter-original.svg" alt="vk" width="25" height="25"/> | **Библиотека API:** Гем `vkontakte_api` для взаимодействия с API ВКонтакте через Long Poll. |
| **HTTP client (Faraday)** | <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/go/go-original.svg" alt="faraday" width="25" height="25"/> | **HTTP Клиент:** Используется для надежной отправки запросов и JSON-парсинга ответов от Long Poll сервера. |
| **Git** | <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/git/git-original.svg" alt="git" width="25" height="25"/> | **Контроль версий:** Мы использовали ветки `develop` и `main` для безопасного процесса разработки. |
| **Dotenv** | ⚙️ | **Конфигурация:** Гем `dotenv` для безопасного хранения токенов в файле `.env`. |

---
