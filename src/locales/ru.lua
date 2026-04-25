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
    },
    errors = {
      invalid_locale_name = "Имя локали должно быть строкой.",
      failed_to_load = "Не удалось загрузить выбранную локаль.",
      invalid_locale_module = "В выбранной локали отсутствуют обязательные строки.",
    },
  },
}

return locale
