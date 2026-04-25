local locale = {
  code = "en",
  name = "English",
  strings = {
    home = {
      title = "TextMonitorCC",
      body = "Starter screen ready for monitor content.",
      footer = "%uptime% | %time%",
    },
    status = {
      ready = "Ready",
      waiting_for_monitor = "Waiting for an attached monitor.",
    },
    errors = {
      invalid_locale_name = "Locale name must be a string.",
      failed_to_load = "Could not load the selected locale.",
      invalid_locale_module = "The selected locale is missing required strings.",
    },
  },
}

return locale
