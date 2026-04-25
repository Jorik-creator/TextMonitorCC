local registry = require("config.registry")

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

  local locale = select_from("Select locale", registry.locales)
  local preset = select_from("Select preset", registry.presets)

  return {
    locale = locale,
    preset = preset,
  }
end

return selector
