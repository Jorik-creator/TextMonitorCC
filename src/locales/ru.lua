local alphabet = require("locales.alphabet.ru")

local locale = {
  code = "ru",
  name = "Русский",
  text_transform = alphabet.replace,
  strings = {
    home = {
      title = "TextMonitorCC",
      body = "Начальный экран готов к отображению.",
      footer = "%uptime% | %time%",
    },
    status = {
      ready = "Готово",
      waiting_for_monitor = "Ожидание подключённого монитора.",
      connected = "Подключено",
      disconnected = "Отключено",
      server_started = "Сервер запущен",
      client_connected = "Подключено к серверу",
    },
    errors = {
      invalid_locale_name = "Имя локали должно быть строкой.",
      failed_to_load = "Не удалось загрузить выбранную локаль.",
      invalid_locale_module = "В выбранной локали отсутствуют обязательные строки.",
      no_monitors = "Мониторы не найдены.",
      no_wireless_modem = "Беспроводной модем не найден.",
      no_servers_found = "Серверы в сети не найдены.",
      connection_timeout = "Таймаут подключения.",
      connection_failed = "Ошибка подключения.",
    },
    server = {
      title = "Режим сервера",
      monitor_select = "Выберите мониторы для отображения сервера:",
      selected_monitors = "Выбрано %count% монитор(ов) для сервера",
      commands = "Команды: Enter = отправить | Ctrl+C = выход",
      broadcast_sent = "Отправлено %count% клиент(ам)",
    },
    client = {
      title = "Режим клиента",
      monitor_select = "Выберите монитор для клиента:",
      single_monitor = "Режим клиента поддерживает только один монитор. Используем первый.",
      searching = "Поиск серверов...",
      found_servers = "Найдены серверы:",
      enter_id = "Введите ID сервера или номер:",
      connecting = "Запуск режима клиента...",
    },
  },
}

return locale
