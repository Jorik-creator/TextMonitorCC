local selector = {}

local function print_options(title, options)
  print(title .. ":")
  for i, opt in ipairs(options) do
    print("  " .. i .. ". " .. opt.id .. " (" .. opt.name .. ")")
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

  local locales = {
    { id = "en", name = "English" },
    { id = "ru", name = "Russian" },
  }
  local presets = {
    { id = "default", name = "Default" },
    { id = "minimal", name = "Minimal" },
  }

  local locale = select_from("Select locale", locales)
  local preset = select_from("Select preset", presets)

  return {
    locale = locale,
    preset = preset,
  }
end

return selector