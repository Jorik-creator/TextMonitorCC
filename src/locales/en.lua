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
      connected = "Connected",
      disconnected = "Disconnected",
      server_started = "Server started",
      client_connected = "Connected to server",
    },
    errors = {
      invalid_locale_name = "Locale name must be a string.",
      failed_to_load = "Could not load the selected locale.",
      invalid_locale_module = "The selected locale is missing required strings.",
      no_monitors = "No monitors found.",
      no_wireless_modem = "No wireless modem found.",
      no_servers_found = "No servers found on network.",
      connection_timeout = "Connection timeout.",
      connection_failed = "Connection failed.",
    },
    server = {
      title = "Server Mode",
      monitor_select = "Select monitors for server display:",
      selected_monitors = "Selected %count% monitor(s) for server",
      commands = "Commands: Enter = broadcast | Ctrl+C = exit",
      broadcast_sent = "Broadcast sent to %count% client(s)",
    },
    client = {
      title = "Client Mode",
      monitor_select = "Select monitor for client display:",
      single_monitor = "Client mode only supports one monitor. Using first selected.",
      searching = "Searching for servers...",
      found_servers = "Found servers:",
      enter_id = "Enter server ID or number:",
      connecting = "Starting client mode...",
    },
  },
}

return locale
