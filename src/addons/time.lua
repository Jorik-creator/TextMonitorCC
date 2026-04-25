local time = {}

function time.get()
  local now = os.date("*t")
  return string.format("%02d:%02d", now.hour, now.min)
end

return time