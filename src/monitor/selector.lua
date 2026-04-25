local manager = require("monitor.manager")

local selector = {}

-- Lists all available monitors with selection checkboxes.
-- Returns array of selected monitor states.
function selector.select(config)
  local normalized_config = {
    scale = config and config.scale or 1,
  }

  -- Get all monitors
  local monitors, monitor_error = manager.attach_all(normalized_config)

  if not monitors then
    return nil, monitor_error
  end

  if #monitors == 0 then
    return nil, "no monitors found"
  end

  -- If only one monitor, select it automatically
  if #monitors == 1 then
    print("Single monitor detected: " .. monitors[1].name)
    return monitors
  end

  print("Available monitors:")
  print()

  -- Selection state: true = selected, false = not selected
  local selection = {}
  for i = 1, #monitors do
    selection[i] = true -- All selected by default
  end

  local function print_list()
    for i = 1, #monitors do
      local state = monitors[i]
      local checkbox = selection[i] and "[x]" or "[ ]"
      local dims = state.width .. "x" .. state.height
      print("  " .. checkbox .. " " .. i .. ". " .. state.name .. " (" .. dims .. ")")
    end
    print()
    print("Commands: number = toggle | a = all | n = none | Enter = confirm")
  end

  print_list()

  while true do
    write("> ")
    local input = read()

    if input == "" or input == nil then
      -- Confirm: collect selected monitors
      local selected = {}
      for i = 1, #monitors do
        if selection[i] then
          table.insert(selected, monitors[i])
        end
      end

      if #selected == 0 then
        print("Select at least one monitor.")
      else
        return selected
      end
    elseif input == "a" or input == "A" then
      for i = 1, #monitors do
        selection[i] = true
      end
      print_list()
    elseif input == "n" or input == "N" then
      for i = 1, #monitors do
        selection[i] = false
      end
      print_list()
    else
      -- Try to parse as number
      local num = tonumber(input)
      if num and num >= 1 and num <= #monitors then
        selection[num] = not selection[num]
        print_list()
      else
        print("Invalid input. Enter number, a, n, or press Enter.")
      end
    end
  end
end

return selector