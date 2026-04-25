local discovery = {}

local function is_valid_scale(scale)
  if type(scale) ~= "number" then
    return false
  end

  if scale < 0.5 or scale > 5 then
    return false
  end

  return scale * 2 == math.floor(scale * 2)
end

local function normalize_config(config)
  if type(config) ~= "table" then
    return nil, "invalid monitor config"
  end

  local scale = config.scale or 1

  if not is_valid_scale(scale) then
    return nil, "invalid monitor scale"
  end

  return {
    scale = scale,
  }
end

function discovery.connect(config)
  local normalized, error_message = normalize_config(config)

  if not normalized then
    return nil, error_message
  end

  local monitor = peripheral.find("monitor")

  if not monitor then
    return nil, "no monitor found"
  end

  monitor.setTextScale(normalized.scale)

  return monitor
end

return discovery
