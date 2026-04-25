local uptime = {}

--- Returns time since computer started in H:MM:SS or M:SS format.
-- @return (string) Formatted uptime
function uptime.get()
  local seconds = os.clock()
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = math.floor(seconds) % 60
  if h > 0 then
    return string.format("%d:%02d:%02d", h, m, s)
  end
  return string.format("%d:%02d", m, s)
end

return uptime