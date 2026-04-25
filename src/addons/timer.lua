local timer = {}

local function parse_duration(param)
  if not param or param == "" then
    return 60
  end
  local n = tonumber(param)
  if n then
    return n
  end
  local m = tonumber(param:match("(%d+)m") or 0)
  local s = tonumber(param:match("(%d+)s") or 0)
  return m * 60 + s
end

local function format_time(seconds)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = math.floor(seconds) % 60
  if h > 0 then
    return string.format("%d:%02d:%02d", h, m, s)
  end
  return string.format("%d:%02d", m, s)
end

function timer.create(param)
  local duration = parse_duration(param)
  return function(_)
    local elapsed = os.clock()
    local remaining = duration - (elapsed % duration)
    return format_time(remaining)
  end
end

return timer