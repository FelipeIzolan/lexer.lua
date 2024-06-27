-- MIT License
--
-- Copyright (c) 2018 LoganDark
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local function lookupify(src)
  local list = {}

  if type(src) == 'string' then
    for i = 1, src:len() do
      list[src:sub(i, i)] = true
    end
  elseif type(src) == 'table' then
    for i = 1, #src do
      list[src[i]] = true
    end
  end

  return list
end

local alphabet = lookupify('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_')
local whitespace = lookupify(' \n\t\r')

local digits = lookupify('0123456789')
local hex_digits = lookupify('0123456789abcdefABCDEF')
local scientific_digits = lookupify(".Ee+-")

local symbols = lookupify("[]{}():;,")
local operators = lookupify('+-*/%^~=><')
local arithmetic_operators = lookupify('+-*/%^')
local relational_operators = lookupify('~=><')

local keywords = {
  structure = lookupify({
    'and', 'break', 'do', 'else', 'elseif', 'end', 'for', 'function',
    'goto', 'if', 'in', 'local', 'not', 'or', 'repeat', 'return', 'then',
    'until', 'while', '<const>'
  }),

  value = lookupify({
    'true', 'false', 'nil'
  })
}

return function(src, opts)
  opts = opts or {}

  local pos = 1
  local start = 1
  local tokens = {}

  local function look(delta)
    delta = pos + (delta or 0)
    return src:sub(delta, delta)
  end

  local function get()
    pos = pos + 1
    return look(-1)
  end

  local function pushToken(type, data)
    data = data or src:sub(start, pos - 1)

    local token = {
      type = type,
      data = data,
      posStart = start,
      posEnd = pos - 1
    }

    if token.data ~= '' then
      table.insert(tokens, token)
    end

    start = pos

    return token
  end

  local function newline()
    while look() == "\n" do
      get()
    end

    if opts.newline then
      pushToken('newline')
    else
      start = pos
    end
  end

  local function chompWhitespace()
    while true do
      local char = look()

      if char == '\n' then
        newline()
      elseif whitespace[char] then
        get()
        if opts.whitespace then
          pushToken('whitespace')
        end
      else
        break
      end
    end

    start = pos
  end

  local function chompComment()
    while true do
      local char = look()

      if char == "-" and look(1) == '-' then
        local is_block_comment = look(2) == "[" and look(3) == "["
        while true do
          local c = look()

          if (is_block_comment and c == "]" and look(-1) == "]") or (not is_block_comment and look() == '\n') then
            get()
            start = pos + 1
            break
          end

          get()
        end
      else
        break
      end
    end
  end

  local tokenizer = {
    ['string'] = function(init)
      local level = 0

      if init == '[' then
        while look() == '=' do
          level = level + 1
          get()
        end
        get()
      end

      pushToken("string:start")
      -----------------------------
      while true do
        local char = get()
        local next_char = look()

        if init ~= '[' and next_char == init and char ~= '\\' then
          break
        end

        if init == '[' and next_char == ']' and look(level + 1) == ']' then
          break
        end

        if pos == #src then
          error("The program failed to identify the string closure token: " .. tokens[#tokens].data:gsub('%[', ']'))
        end
      end

      pushToken('string')
      -----------------------------
      get()
      if init == '[' then
        while look() == '=' do
          get()
        end
        get()
      end

      pushToken("string:end")
    end,
    ['word'] = function()
      local token = look(-1)

      while alphabet[look()] or digits[look()] do
        token = token .. get()
      end

      if keywords.structure[token] then
        pushToken('keyword')
      elseif keywords.value[token] then
        pushToken((token == 'true' or token == 'false') and 'boolean' or 'nil')
      elseif tokens[#tokens].data == "goto" then
        pushToken('label')
      else
        pushToken('identifier')
      end
    end,
    ['number'] = function()
      if look(-1) == '0' and look() == 'x' then
        get()
        while hex_digits[look()] do
          get()
        end
      else
        while digits[look()] or scientific_digits[look()] do
          get()
        end
      end

      pushToken('number')
    end,
    ['point'] = function()
      for _ = 1, 2 do
        if look() == '.' then
          get()
        else
          break
        end
      end

      local length = src:sub(start, pos - 1):len()
      pushToken(length == 3 and 'vararg' or length == 2 and 'operator' or 'symbol')
    end,
    ['label'] = function()
      get()

      pushToken('label:start')
      chompWhitespace()

      while alphabet[look()] or digits[look()] do
        get()
      end

      pushToken('label')

      chompWhitespace()
      if look() == ':' and look(1) == ':' then
        get()
        get()

        pushToken('label:end')
      else
        error("The program failed to identify the label closure token: '::'")
      end
    end,
    ['operator'] = function()
      local operator = look(-1)
      local next = look()

      if arithmetic_operators[operator] and ((opts.extended_assignment and next == '=') or (operator == '/' and next == '/')) then
        get()
      end

      if relational_operators[operator] and next == '=' then
        get()
      end

      pushToken("operator")
    end,
  }

  local is = {
    ['string'] = function(char, next_char)
      return char == '\'' or char == '"' or (char == '[' and (next_char == '[' or next_char == '='))
    end,
    ['word'] = function(char)
      return alphabet[char]
    end,
    ['number'] = function(char, next_char)
      return digits[char] or (char == '.' and digits[next_char])
    end,
    ['point'] = function(char)
      return char == '.'
    end,
    ['label'] = function(char, next_char)
      return char == ':' and next_char == ':'
    end,
    ['operator'] = function(char)
      return operators[char] or char == "#"
    end,
    ['symbol'] = function(char)
      return symbols[char]
    end
  }

  while true do
    chompWhitespace()
    chompComment()

    local char = get()
    local next_char = look()

    if char == '' then
      break
    end

    local _ =
        is.string(char, next_char) and tokenizer.string(char) or
        is.word(char) and tokenizer.word() or
        is.number(char, next_char) and tokenizer.number() or
        is.point(char) and tokenizer.point() or
        is.label(char, next_char) and tokenizer.label() or
        is.operator(char) and tokenizer.operator() or
        is.symbol(char) and pushToken('symbol') or
        pushToken('undefined')
  end

  return tokens
end
