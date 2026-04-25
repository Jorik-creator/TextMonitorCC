local renderer = require("render.renderer")
local preset_loader = require("presets.loader")
local locale_loader = require("locales")

local server = {}

local PROTOCOL = "textmonitor"
local UPDATE_INTERVAL = 1

-- Connected clients: { [id] = true }
local clients = {}

local function load_assets(config)
  local preset, preset_error = preset_loader.load(config.preset)
  if not preset then
    return nil, preset_error
  end

  local locale, locale_error = locale_loader.load(config.locale)
  if not locale then
    return nil, locale_error
  end

  return {
    preset = preset,
    locale = locale,
  }
end

local function render_all(monitor_states, assets)
  for _, state in ipairs(monitor_states) do
    local ok, err = renderer.render_home(state, assets)
    if not ok then
      return false, err
    end
  end
  return true
end

-- Broadcast message to all connected clients
local function broadcast(message)
  for client_id, _ in pairs(clients) do
    rednet.send(client_id, message, PROTOCOL)
  end
end

-- Broadcast render command to all clients
local function broadcast_render(assets, custom_content)
  local message = {
    action = "render",
    locale = assets.locale.code,
    preset = assets.preset and assets.preset._name or "default",
  }

  if custom_content then
    message.content = custom_content
  end

  broadcast(message)
end

-- Handle incoming rednet messages
local function handle_message(sender_id, message)
  if type(message) ~= "table" then
    return
  end

  if message.action == "discover" then
    -- Respond to discovery request
    rednet.send(sender_id, {
      action = "status",
      server_id = os.getComputerID(),
      client_count = server.get_client_count(),
    }, PROTOCOL)

  elseif message.action == "connect" then
    -- New client connecting
    clients[sender_id] = true
    print("Client connected: " .. sender_id)
    rednet.send(sender_id, { action = "ack", status = "ok" }, PROTOCOL)

  elseif message.action == "disconnect" then
    -- Client disconnecting
    clients[sender_id] = nil
    print("Client disconnected: " .. sender_id)

  elseif message.action == "status" then
    -- Status request
    rednet.send(sender_id, {
      action = "status",
      server_id = os.getComputerID(),
      client_count = server.get_client_count(),
    }, PROTOCOL)
  end
end

-- Main server loop
local function server_loop(monitor_states, assets, modem_side)
  local next_update = 0

  while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "timer" and p1 == next_update then
      render_all(monitor_states, assets)
      next_update = os.startTimer(UPDATE_INTERVAL)

    elseif event == "rednet_message" then
      local sender_id, message = p1, p2
      handle_message(sender_id, message)

    elseif event == "key" then
      -- Handle key press for server commands
      local key = p1
      if key == keys.enter then
        -- Force broadcast current content
        broadcast_render(assets)
        print("Broadcast sent to " .. #clients .. " client(s)")
      end
    end
  end
end

-- Start server mode
function server.start(config, monitor_states)
  local modem = require("monitor.modem")

  -- Open modem
  local modem_side, modem_error = modem.open()
  if not modem_side then
    return false, modem_error
  end

  -- Load initial assets
  local assets, assets_error = load_assets({
    locale = config.locale,
    preset = config.preset,
  })

  if not assets then
    modem.close(modem_side)
    return false, assets_error
  end

  print("Server started (protocol: " .. PROTOCOL .. ")")
  print("Computer ID: " .. os.getComputerID())
  print("Connected clients: 0")
  print()
  print("Commands: Enter = broadcast | Ctrl+C = exit")
  print()

  -- Initial render
  render_all(monitor_states, assets)

  -- Start server loop
  return server_loop(monitor_states, assets, modem_side)
end

-- Update assets and broadcast to clients
function server.update(assets, monitor_states)
  if not assets then
    return false, "no assets"
  end

  render_all(monitor_states, assets)
  broadcast_render(assets)
  return true
end

-- Send custom content to all clients
function server.broadcast_content(assets, content, monitor_states)
  render_all(monitor_states, assets)
  broadcast_render(assets, content)
  return true
end

-- Get connected client count
function server.get_client_count()
  local count = 0
  for _ in pairs(clients) do
    count = count + 1
  end
  return count
end

return server