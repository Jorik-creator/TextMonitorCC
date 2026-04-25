local client = {}

local PROTOCOL = "textmonitor"

-- Current state
local server_id = nil
local connected = false
local monitor_state = nil

-- ============================================
-- Standalone addon parser (no external deps)
-- ============================================
local addon_time = {}
function addon_time.get()
  local h = os.time()
  local hh = math.floor(h / 3600) % 24
  local mm = math.floor(h / 60) % 60
  return string.format("%02d:%02d", hh, mm)
end

local addon_uptime = {}
function addon_uptime.get()
  local s = os.clock()
  local h = math.floor(s / 3600)
  local m = math.floor((s % 3600) / 60)
  local sec = math.floor(s) % 60
  if h > 0 then
    return string.format("%d:%02d:%02d", h, m, sec)
  end
  return string.format("%d:%02d", m, sec)
end

local addon_timer = {}
function addon_timer.create(param)
  local function parse_duration(p)
    if not p or p == "" then return 60 end
    local n = tonumber(p)
    if n then return n end
    local m = tonumber(p:match("(%d+)m") or "0")
    local sec = tonumber(p:match("(%d+)s") or "0")
    return m * 60 + sec
  end
  local function format_time(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = math.floor(sec) % 60
    if h > 0 then
      return string.format("%d:%02d:%02d", h, m, s)
    end
    return string.format("%d:%02d", m, s)
  end
  local duration = parse_duration(param)
  return function(_)
    local elapsed = os.clock()
    local remaining = duration - (elapsed % duration)
    return format_time(remaining)
  end
end

-- Registry
local addon_registry = {
  time = addon_time,
  timer = addon_timer,
  uptime = addon_uptime,
}

-- Resolve addons in text
local function resolve_addons(text)
  if type(text) ~= "string" then
    return text or ""
  end
  local result = (text:gsub("%%(%w+):?([^%%]*)%%", function(name, param)
    local addon = addon_registry[name]
    if not addon then
      return "%" .. name .. (param ~= "" and ":" .. param or "") .. "%"
    end
    if addon.create then
      return addon.create(param)()
    end
    if addon.get then
      return addon.get()
    end
    return "%" .. name .. (param ~= "" and ":" .. param or "") .. "%"
  end))
  return result
end

-- ============================================
-- Connection
-- ============================================
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

local function discover_servers()
  local modem = require("monitor.modem")

  local modem_side, modem_error = modem.open()
  if not modem_side then
    return nil, modem_error
  end

  print("Searching for servers...")

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

-- ============================================
-- Rendering
-- ============================================
local function render_screen(screen_data)
  local monitor = monitor_state.monitor
  local background = screen_data.background

  monitor.setBackgroundColor(background)
  monitor.clear()

  local width, height = monitor.getSize()
  local body_lines = screen_data.body and screen_data.body.lines or {}
  local line_count = #body_lines

  local footer_lines = {}
  local footer_height = 0
  if screen_data.footer and screen_data.footer.lines then
    footer_lines = screen_data.footer.lines
    footer_height = #footer_lines
  end

  local body_height = height - footer_height
  local start_y = math.max(1, math.floor(body_height / 2) - math.floor(line_count / 2) + 1)

  -- Draw body with resolved addons
  for i, line in ipairs(body_lines) do
    local y = start_y + i - 1
    if y > 0 and y <= body_height then
      local text = resolve_addons(line.text)
      local x = 1
      if line.align == "center" then
        x = math.max(1, math.floor((width - #text) / 2) + 1)
      elseif line.align == "right" then
        x = math.max(1, width - #text + 1)
      end
      monitor.setCursorPos(x, y)
      monitor.setTextColor(line.color)
      monitor.write(text)
    end
  end

  -- Draw footer with resolved addons
  if footer_height > 0 then
    local footer_y = height - footer_height + 1
    local footer_data = screen_data.footer
    for i, line_text in ipairs(footer_lines) do
      local text = resolve_addons(line_text)
      local y = footer_y + i - 1
      local x = 1
      if footer_data.align == "center" then
        x = math.max(1, math.floor((width - #text) / 2) + 1)
      elseif footer_data.align == "right" then
        x = math.max(1, width - #text + 1)
      end
      monitor.setCursorPos(x, y)
      monitor.setTextColor(footer_data.color)
      monitor.write(text)
    end
  end
end

-- ============================================
-- Main loop
-- ============================================
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
          print("Server: " .. message.client_count .. " client(s)")
        end
      end
    end
  end
end

-- ============================================
-- Entry point
-- ============================================
function client.start(config, target_monitor_state)
  monitor_state = target_monitor_state

  -- Connect with optional server_id
  if config and config.server_id then
    local ok, err = connect_to_server(config.server_id)
    if not ok then
      return false, err
    end
    client_loop()
    return true
  end

  -- Discover servers
  local servers, discover_error = discover_servers()
  if not servers then
    return false, discover_error
  end

  if #servers == 0 then
    return false, "no servers found"
  end

  if #servers == 1 then
    print("Server found: " .. servers[1].id)
    local ok, err = connect_to_server(servers[1].id)
    if not ok then
      return false, err
    end
    client_loop()
    return true
  end

  -- Multiple servers - select
  print("Servers found:")
  for i, s in ipairs(servers) do
    print("  " .. i .. ". ID " .. s.id .. " (" .. s.client_count .. " clients)")
  end
  print()

  write("> ")
  local input = read()
  local num = tonumber(input)
  if num and num >= 1 and num <= #servers then
    local ok, err = connect_to_server(servers[num].id)
    if not ok then
      return false, err
    end
    client_loop()
    return true
  end

  return false, "invalid selection"
end

return client