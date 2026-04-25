local loader = {}

local VALID_ALIGNMENTS = {
  left = true,
  center = true,
  right = true,
}

local function is_valid_line(line)
  if type(line) ~= "table" then
    return false
  end

  return type(line.text_key) == "string"
    and VALID_ALIGNMENTS[line.align] ~= nil
    and type(line.color_token) == "string"
end

local function is_valid_lines(lines)
  if type(lines) ~= "table" then
    return false
  end

  for i = 1, #lines do
    if not is_valid_line(lines[i]) then
      return false
    end
  end

  return true
end

local function is_valid_footer(footer)
  if type(footer) ~= "table" then
    return false
  end

  return type(footer.text_key) == "string"
    and VALID_ALIGNMENTS[footer.align] ~= nil
    and type(footer.color_token) == "string"
end

local function is_home_template(template)
  if type(template) ~= "table" then
    return false
  end

  return is_valid_lines(template.lines)
    and type(template.footer_enabled) == "boolean"
    and type(template.footer_height) == "number"
    and (not template.footer_enabled or is_valid_footer(template.footer))
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
