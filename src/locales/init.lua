local locales = {
  DEFAULT_LOCALE_NAME = "en",
}

local function has_string_fields(values, required_keys)
  if type(values) ~= "table" then
    return false
  end

  for index = 1, #required_keys do
    local key = required_keys[index]

    if type(values[key]) ~= "string" then
      return false
    end
  end

  return true
end

local function is_valid_locale(locale)
  if type(locale) ~= "table" or type(locale.strings) ~= "table" then
    return false
  end

  return has_string_fields(locale.strings.home, { "title", "body", "footer" })
    and has_string_fields(locale.strings.status, { "ready", "waiting_for_monitor" })
    and has_string_fields(locale.strings.errors, {
      "invalid_locale_name",
      "failed_to_load",
      "invalid_locale_module",
    })
end

local function resolve_locale_name(name)
  if name == nil then
    return locales.DEFAULT_LOCALE_NAME
  end

  if type(name) ~= "string" or name == "" then
    return nil, "invalid locale name"
  end

  return name
end

function locales.load(name)
  local locale_name, name_error = resolve_locale_name(name)

  if not locale_name then
    return nil, name_error
  end

  local module_name = "locales." .. locale_name
  local ok, locale = pcall(require, module_name)

  if not ok then
    return nil, "failed to load locale module: " .. module_name
  end

  if not is_valid_locale(locale) then
    return nil, "invalid locale module: " .. module_name
  end

  return locale
end

return locales
