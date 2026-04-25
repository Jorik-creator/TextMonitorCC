local discovery = require("monitor.discovery")

local manager = {}

local function normalize_config(config)
  if type(config) ~= "table" then
    return nil, "invalid monitor manager config"
  end

  return {
    scale = config.scale or 1,
  }
end

local function build_state(monitor, config)
  local width, height = monitor.getSize()

  return {
    monitor = monitor,
    name = peripheral.getName(monitor),
    width = width,
    height = height,
    scale = config.scale,
  }
end

function manager.attach(config)
  local normalized, config_error = normalize_config(config)

  if not normalized then
    return nil, config_error
  end

  local monitor, monitor_error = discovery.connect(normalized)

  if not monitor then
    return nil, monitor_error
  end

  return build_state(monitor, normalized)
end

function manager.refresh(state)
  if type(state) ~= "table"
    or type(state.monitor) ~= "table"
    or type(state.monitor.getSize) ~= "function" then
    return nil, "invalid monitor state"
  end

  return build_state(state.monitor, { scale = state.scale or 1 })
end

return manager
