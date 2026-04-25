local modem_module = {}

local PROTOCOL = "textmonitor"

local function find_wireless_modem()
  for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "modem" then
      local m = peripheral.wrap(name)
      if m.isWireless() then
        return name
      end
    end
  end
  return nil
end

-- Opens rednet on the first wireless modem found.
-- Returns modem side name, or nil + error message if no wireless modem present.
function modem_module.open()
  local side = find_wireless_modem()

  if not side then
    return nil, "no wireless modem found"
  end

  rednet.open(side)
  return side
end

-- Enters a blocking receive loop on the textmonitor protocol.
-- Calls on_command(sender_id, message) for each valid incoming table.
-- If on_command returns a non-nil value, it is sent back to the sender.
function modem_module.listen(on_command)
  while true do
    local sender_id, message = rednet.receive(PROTOCOL)

    if type(message) == "table" and type(message.action) == "string" then
      local response = on_command(sender_id, message)

      if response ~= nil then
        rednet.send(sender_id, response, PROTOCOL)
      end
    end
  end
end

function modem_module.close(side)
  if type(side) == "string" then
    rednet.close(side)
  end
end

return modem_module
