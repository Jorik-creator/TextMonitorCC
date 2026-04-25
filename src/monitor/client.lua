local renderer = require("render.renderer")
local preset_loader = require("presets.loader")
local locale_loader = require("locales")

local client = {}

local PROTOCOL = "textmonitor"

-- Current state
local server_id = nil
local connected = false
local monitor_state = nil
local current_assets = nil
local auto_reconnect = true

local function load_assets(config)
  local preset, preset_error = preset_loader.load(config.preset or "default")
  if not preset then
    return nil, preset_error
  end

  local locale, locale_error = locale_loader.load(config.locale or "en")
  if not locale then
    return nil, locale_error
  end

  return {
    preset = preset,
    locale = locale,
  }
end

-- Merge custom content into assets if provided
local function merge_content(assets, content)
  if not content or type(content) ~= "table" then
    return assets
  end

  -- Create a copy with merged strings
  local merged = {
    preset = assets.preset,
    locale = {
      code = assets.locale.code,
      name = assets.locale.name,
      text_transform = assets.locale.text_transform,
      strings = {
        home = {},
      },
    },
  }

  -- Copy existing strings
  for section, strings in pairs(assets.locale.strings) do
    merged.locale.strings[section] = strings
  end

  -- Override home strings with custom content
  if content.title then
    merged.locale.strings.home.title = content.title
  end
  if content.body then
    merged.locale.strings.home.body = content.body
  end
  if content.footer then
    merged.locale.strings.home.footer = content.footer
  end

  return merged
end

-- Connect to server
local function connect_to_server(target_server_id)
  local modem = require("monitor.modem")

  -- Open modem if not already open
  local modem_side, modem_error = modem.open()
  if not modem_side then
    return false, modem_error
  end

  -- Send connection request
  server_id = target_server_id
  rednet.send(server_id, { action = "connect" }, PROTOCOL)

  -- Wait for acknowledgment
  local timeout = 5 -- seconds
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

  -- Broadcast discovery request
  rednet.send(nil, { action = "discover" }, PROTOCOL)

  -- Collect responses
  local servers = {}
  local timeout = 3 -- seconds
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

  -- Convert to array
  local result = {}
  for id, server in pairs(servers) do
    table.insert(result, server)
  end

  return result
end

-- Render content received from server
local function handle_render(message)
  local config = {
    locale = message.locale or "en",
    preset = message.preset or "default",
  }

  local assets, load_error = load_assets(config)
  if not assets then
    print("Failed to load assets: " .. tostring(load_error))
    return
  end

  -- Merge custom content if provided
  if message.content then
    assets = merge_content(assets, message.content)
  end

  current_assets = assets

  if monitor_state then
    renderer.render_home(monitor_state, assets)
  end
end

-- Main client loop
local function client_loop()
  local UPDATE_INTERVAL = 1
  local next_update = 0

  while connected do
    local event, p1, p2 = os.pullEvent()

    if event == "timer" and p1 == next_update then
      next_update = os.startTimer(UPDATE_INTERVAL)

    elseif event == "rednet_message" then
      local sender_id, message = p1, p2
      if sender_id == server_id and type(message) == "table" then
        if message.action == "render" then
          handle_render(message)

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

  -- If server ID provided directly
  if config.server_id then
    local ok, err = connect_to_server(config.server_id)
    if not ok then
      return false, err
    end
    client_loop()
    return true
  end

  -- Otherwise, discover servers
  local servers, discover_error = discover_servers()

  if not servers then
    return false, discover_error
  end

  if #servers == 0 then
    return false, "no servers found on network"
  end

  -- If only one server, auto-connect
  if #servers == 1 then
    print("Single server found: " .. servers[1].id)
    local ok, err = connect_to_server(servers[1].id)
    if not ok then
      return false, err
    end
    client_loop()
    return true
  end

  -- Multiple servers: let user choose
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
    -- Try to find by number
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

-- Get current connection status
function client.is_connected()
  return connected
end

-- Get connected server ID
function client.get_server_id()
  return server_id
end

return client