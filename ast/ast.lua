package.path = "../*/?.lua;../?.lua;" .. package.path

local lexer = require('lexer.lexer')

function ast(src)
  local tokens = lexer(src)
  local root = {}

  local pos = 1

  local function look(delta)
    delta = pos + (delta or 0)
    return tokens[delta]
  end

  local function get()
    pos = pos + 1
    return look(-1)
  end

  local function parse(curr)
  end

  while look() ~= nil do
    local curr = get()

    parse(curr)
  end
end
