local time = require("addons.time")
local timer = require("addons.timer")
local uptime = require("addons.uptime")

local addons = {}

-- Registry: addon_name -> addon_module
local registry = {
  time = time,
  timer = timer,
  uptime = uptime,
}

-- Replaces all %addon% or %addon:param% placeholders in text.
function addons.replace(text)
  if type(text) ~= "string" then
    return text
  end

  return (text:gsub("%%(%w+):?([^%%]*)%%", function(name, param)
    local addon = registry[name]
    if not addon then
      return "%" .. name .. (param ~= "" and ":" .. param or "") .. "%"
    end

    -- Support both create(param) and get() APIs
    local create_fn = addon.create
    if create_fn then
      return create_fn(param)()
    end

    local get_fn = addon.get
    if get_fn then
      return get_fn()
    end

    return "%" .. name .. (param ~= "" and ":" .. param or "") .. "%"
  end))
end

return addons