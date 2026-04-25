local loader = {}

local function is_home_template(template)
  if type(template) ~= "table" then
    return false
  end

  return type(template.footer_enabled) == "boolean"
    and type(template.footer_height) == "number"
end

function loader.load(name)
  if name ~= nil and type(name) ~= "string" then
    return nil, "invalid template name"
  end

  local module_name = "templates." .. (name or "basic")
  local ok, template = pcall(require, module_name)

  if not ok then
    return nil, "failed to load template module: " .. module_name
  end

  if type(template) ~= "table" or not is_home_template(template.home) then
    return nil, "invalid template module: " .. module_name
  end

  return template
end

return loader
