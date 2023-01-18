local json = require('debugger.json')
local dap = require('dap')
local fs = require('plenary.path')

local M = {}

M.setup = function()
  local debug_file = fs.new(vim.fn.getcwd()) / 'debug.json'
  if (not debug_file:exists()) then
    return
  end

  local conf = json.decode(debug_file:read())

  for name in pairs(conf) do
    if (not dap.configurations[name]) then
      dap.configurations[name] = {}
    end

    table.insert(dap.configurations[name], conf[name])
  end
end

return M
