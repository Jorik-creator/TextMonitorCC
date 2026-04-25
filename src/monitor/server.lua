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

-- Build screen data for transmission to clients (raw text with placeholders)
local function build_screen_data(monitor_state, assets)
  local tokens = assets.preset.tokens
  local strings = assets.locale.strings.home

  -- Build body lines with RAW text (no addon processing)
  local body_lines = {}
  local home = assets.preset.home
  for i, line_config in ipairs(home.lines) do
    local text = strings[line_config.text_key] or ""
    local text_lines = {}
    for line in text:gmatch("[^\n]+") do
      table.insert(text_lines, line)
    end
    for j, line_text in ipairs(text_lines) do
      table.insert(body_lines, {
        y = j,
        text = line_text,
        align = line_config.align,
        color = tokens[line_config.color_token],
      })
    end
  end

  -- Build footer
  local footer_data = nil
  if home.footer_enabled and home.footer then
    local footer_lines = {}
    local footer_text = strings[home.footer.text_key] or ""
    for line in footer_text:gmatch("[^\n]+") do
      table.insert(footer_lines, line)
    end
    footer_data = {
      align = home.footer.align,
      color = tokens[home.footer.color_token],
      lines = footer_lines,
    }
  end

  return {
    background = tokens.background,
    body = {
      lines = body_lines,
    },
    footer = footer_data,
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

-- Broadcast render command to all clients with screen data
local function broadcast_render(monitor_states, assets)
  local screen_data = build_screen_data(monitor_states[1], assets)
  broadcast({
    action = "render",
    screen = screen_data,
  })
end

-- Handle incoming rednet messages
local function handle_message(sender_id, message)
  if type(message) ~= "table" then
    return
  end

  if message.action == "discover" then
    rednet.send(sender_id, {
      action = "status",
      server_id = os.getComputerID(),
      client_count = server.get_client_count(),
    }, PROTOCOL)

  elseif message.action == "connect" then
    clients[sender_id] = true
    print("Client connected: " .. sender_id)
    rednet.send(sender_id, { action = "ack", status = "ok" }, PROTOCOL)

  elseif message.action == "disconnect" then
    clients[sender_id] = nil
    print("Client disconnected: " .. sender_id)

  elseif message.action == "status" then
    rednet.send(sender_id, {
      action = "status",
      server_id = os.getComputerID(),
      client_count = server.get_client_count(),
    }, PROTOCOL)
  end
end

-- Main server loop
local function server_loop(monitor_states, assets, modem_side)
  local next_update = os.startTimer(UPDATE_INTERVAL)

  while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "timer" and p1 == next_update then
      render_all(monitor_states, assets)
      if server.get_client_count() > 0 then
        broadcast_render(monitor_states, assets)
      end
      next_update = os.startTimer(UPDATE_INTERVAL)

    elseif event == "rednet_message" then
      local sender_id, message = p1, p2
      handle_message(sender_id, message)

    elseif event == "key" then
      local key = p1
      if key == keys.enter then
        broadcast_render(monitor_states, assets)
        print("Broadcast sent to " .. server.get_client_count() .. " client(s)")
      end
    end
  end
end

-- Start server mode
function server.start(config, monitor_states)
  local modem = require("monitor.modem")

  local modem_side, modem_error = modem.open()
  if not modem_side then
    return false, modem_error
  end

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

  render_all(monitor_states, assets)
  return server_loop(monitor_states, assets, modem_side)
end

function server.update(assets, monitor_states)
  if not assets then
    return false, "no assets"
  end
  render_all(monitor_states, assets)
  broadcast_render(monitor_states, assets)
  return true
end

function server.get_client_count()
  local count = 0
  for _ in pairs(clients) do
    count = count + 1
  end
  return count
end

return server