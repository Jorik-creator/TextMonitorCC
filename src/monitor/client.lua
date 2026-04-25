local client = {}

local PROTOCOL = "textmonitor"

-- Current state
local server_id = nil
local connected = false
local monitor_state = nil

-- Connect to server
local function connect_to_server(target_server_id)
  local modem = require("monitor.modem")

  local modem_side, modem_error = modem.open()
  if not modem_side then
    return false, modem_error
  end

  server_id = target_server_id
  rednet.send(server_id, { action = "connect" }, PROTOCOL)

  local timeout = 5
  local deadline = os.startTimer(timeout)

  while true do
    local event, p1, p2 = os.pullEvent()

    if event == "timer" and p1 == deadline then
      modem.close(modem_side)
      return false, "connection timeout"
    end

    if event == "rednet_message" then
      local sender_id, message = p1, p2
      if sender_id == server_id and type(message) == "table" then
        if message.action == "ack" and message.status == "ok" then
          connected = true
          print("Connected to server: " .. server_id)
          return true
        end
      end
    end
  end
end

-- Discover servers on the network
local function discover_servers()
  local modem = require("monitor.modem")

  local modem_side, modem_error = modem.open()
  if not modem_side then
    return nil, modem_error
  end

  print("Searching for servers...")
  print()

  rednet.broadcast({ action = "discover" }, PROTOCOL)

  local servers = {}
  local timeout = 3
  local deadline = os.startTimer(timeout)

  while true do
    local event, p1, p2 = os.pullEvent()

    if event == "timer" and p1 == deadline then
      break
    end

    if event == "rednet_message" then
      local sender_id, message = p1, p2
      if type(message) == "table" and message.action == "status" then
        if not servers[sender_id] then
          servers[sender_id] = {
            id = sender_id,
            client_count = message.client_count or 0,
          }
        end
      end
    end
  end

  local result = {}
  for id, server in pairs(servers) do
    table.insert(result, server)
  end

  return result
end

-- Render received screen data directly to monitor
local function render_screen(screen_data)
  local monitor = monitor_state.monitor
  local background = screen_data.background

  -- Clear screen
  monitor.setBackgroundColor(background)
  monitor.clear()

  -- Calculate body start position (center vertically)
  local width, height = monitor.getSize()
  local body_lines = screen_data.body and screen_data.body.lines or {}
  local line_count = #body_lines

  -- Footer handling
  local footer_lines = {}
  local footer_height = 0
  if screen_data.footer and screen_data.footer.lines then
    footer_lines = screen_data.footer.lines
    footer_height = #footer_lines
  end

  -- Body position
  local body_height = height - footer_height
  local start_y = math.max(1, math.floor(body_height / 2) - math.floor(line_count / 2) + 1)

  -- Draw body lines
  for i, line in ipairs(body_lines) do
    local y = start_y + i - 1
    if y > 0 and y <= body_height then
      local x = 1
      if line.align == "center" then
        x = math.max(1, math.floor((width - #line.text) / 2) + 1)
      elseif line.align == "right" then
        x = math.max(1, width - #line.text + 1)
      end
      monitor.setCursorPos(x, y)
      monitor.setTextColor(line.color)
      monitor.setBackgroundColor(background)
      monitor.write(line.text)
    end
  end

  -- Draw footer
  if footer_height > 0 then
    local footer_y = height - footer_height + 1
    local footer_data = screen_data.footer
    for i, line_text in ipairs(footer_lines) do
      local y = footer_y + i - 1
      local x = 1
      if footer_data.align == "center" then
        x = math.max(1, math.floor((width - #line_text) / 2) + 1)
      elseif footer_data.align == "right" then
        x = math.max(1, width - #line_text + 1)
      end
      monitor.setCursorPos(x, y)
      monitor.setTextColor(footer_data.color)
      monitor.setBackgroundColor(background)
      monitor.write(line_text)
    end
  end
end

-- Main client loop
local function client_loop()
  while connected do
    local event, p1, p2 = os.pullEvent()

    if event == "rednet_message" then
      local sender_id, message = p1, p2
      if sender_id == server_id and type(message) == "table" then
        if message.action == "render" and message.screen then
          render_screen(message.screen)

        elseif message.action == "disconnect" then
          connected = false
          print("Disconnected by server")

        elseif message.action == "status" then
          print("Server status: " .. message.client_count .. " client(s)")
        end
      end
    end
  end
end

-- Start client mode
function client.start(config, target_monitor_state)
  monitor_state = target_monitor_state

  if config.server_id then
    local ok, err = connect_to_server(config.server_id)
    if not ok then
      return false, err
    end
    client_loop()
    return true
  end

  local servers, discover_error = discover_servers()

  if not servers then
    return false, discover_error
  end

  if #servers == 0 then
    return false, "no servers found on network"
  end

  if #servers == 1 then
    print("Single server found: " .. servers[1].id)
    local ok, err = connect_to_server(servers[1].id)
    if not ok then
      return false, err
    end
    client_loop()
    return true
  end

  print("Found servers:")
  print()
  for i, server in ipairs(servers) do
    print("  " .. i .. ". Server " .. server.id .. " (" .. server.client_count .. " clients)")
  end
  print()

  write("Enter server ID or number: ")
  local input = read()
  local selected_id = tonumber(input)

  if not selected_id then
    local num = tonumber(input)
    if num and num >= 1 and num <= #servers then
      selected_id = servers[num].id
    else
      return false, "invalid selection"
    end
  end

  local ok, err = connect_to_server(selected_id)
  if not ok then
    return false, err
  end

  client_loop()
  return true
end

function client.is_connected()
  return connected
end

function client.get_server_id()
  return server_id
end

return client