local selector = {}

local MODES = {
  { id = "server", name = "Server (broadcast to clients)" },
  { id = "client", name = "Client (receive from server)" },
}

local LOCALES = {
  { id = "en", name = "English" },
  { id = "ru", name = "Russian" },
}

local PRESETS = {
  { id = "default", name = "Default" },
  { id = "minimal", name = "Minimal" },
}

local function print_options(title, options)
  print(title .. ":")
  for i, opt in ipairs(options) do
    print("  " .. i .. ". " .. opt.name)
  end
end

local function read_choice(options)
  write("> ")
  local input = read()
  local num = tonumber(input)

  if num and num >= 1 and num <= #options then
    return options[num].id
  end

  for _, opt in ipairs(options) do
    if opt.id == input then
      return opt.id
    end
  end

  return nil
end

local function select_from(title, options)
  print_options(title, options)
  local choice = read_choice(options)

  while not choice do
    print("Invalid choice. Try again.")
    print_options(title, options)
    choice = read_choice(options)
  end

  return choice
end

function selector.run()
  print("=== TextMonitorCC ===")
  print()

  local mode = select_from("Select mode", MODES)
  local locale = select_from("Select locale", LOCALES)
  local preset = select_from("Select preset", PRESETS)

  return {
    mode = mode,
    locale = locale,
    preset = preset,
  }
end

function selector.select_mode()
  return select_from("Select mode", MODES)
end

function selector.select_locale()
  return select_from("Select locale", LOCALES)
end

function selector.select_preset()
  return select_from("Select preset", PRESETS)
end

return selector