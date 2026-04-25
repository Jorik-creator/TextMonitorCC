local app = require("monitor.app")

local ok, error_message = app.run()

if not ok then
  print(error_message)
end
