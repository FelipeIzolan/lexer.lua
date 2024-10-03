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

package.path = "../*/?.lua;../?.lua;" .. package.path
require("utils")

local function err(type, token)
  error("The program failed to identify the " .. type .. " token: " .. token)
end

return function(src, opts)
  opts = opts or {}

  local pos = 1
  local start = 1
  local tokens = {}

  local function getCurrentTokenData()
    return src:sub(start, pos - 1)
  end

  local function getLastTokenData()
    return #tokens > 0 and tokens[#tokens].data or nil
  end

  local function pushToken(type, data)
    data = data or getCurrentTokenData()
    local token = {
      type = type,
      data = data,
      range = { start, pos - 1 }
    }

    if token.data ~= '' then
      table.insert(tokens, token)
    end

    start = pos

    return token
  end

  local function look(delta)
    delta = pos + (delta or 0)
    return src:sub(delta, delta)
  end

  local function get()
    pos = pos + 1
    return look(-1)
  end

  local function getSquareBracketLevel()
    local level = 0

    while look() == '=' do
      level = level + 1
      get()
    end

    return level
  end

  local tokenizer = {}

  function tokenizer.whitespace()
    local char = look(-1)

    if opts.whitespace == 'all' or (opts.whitespace == 'newline' and char == '\n') then
      pushToken('whitespace')
    else
      start = pos
    end

    if whitespace[look()] then
      get()
      tokenizer.whitespace()
    end
  end

  function tokenizer.string()
    local string_start = look(-1)
    local level = 0
    ------------------------------------------
    if string_start == '[' then
      level = getSquareBracketLevel()
      get()
    end
    pushToken("string:start")
    ------------------------------------------
    while true do
      local char = get()
      local next_char = look()

      if string_start ~= '[' and char ~= '\\' and next_char == string_start then
        break
      end

      if string_start == '[' and next_char == ']' and look(level + 1) == ']' then
        break
      end

      if pos == #src then
        err('string', getLastTokenData():gsub('%[', ']'))
      end
    end
    pushToken('string')
    ------------------------------------------
    get()
    if string_start == '[' then
      getSquareBracketLevel()
      get()
    end
    pushToken("string:end")
  end

  function tokenizer.word()
    while alphabet[look()] or digits[look()] do
      get()
    end

    local token = getCurrentTokenData()

    if keywords.structure[token] then
      pushToken('keyword')
    elseif keywords.value[token] then
      pushToken((token == 'true' or token == 'false') and 'boolean' or 'nil')
    elseif getLastTokenData() == "goto" then
      pushToken('label')
    else
      pushToken('identifier')
    end
  end

  function tokenizer.number()
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
  end

  function tokenizer.comment()
    local is_block_comment = look(1) == '[' and look(2) == '['

    get()
    if is_block_comment then
      get()
      get()
    end

    if opts.comment then
      pushToken('comment:start')
    end

    while true do
      local c = look()

      if (not is_block_comment and c == '\n') or (is_block_comment and c == ']' and look(1) == ']') then
        if opts.comment then
          pushToken('comment')
        end
        break
      end

      get()
    end

    get()

    if is_block_comment then
      get()
    end

    if opts.comment then
      pushToken('comment:end')
    end

    start = pos
  end

  function tokenizer.point()
    while look() == '.' do
      get()
    end

    local length = getCurrentTokenData():len()
    pushToken(length == 3 and 'vararg' or length == 2 and 'operator' or 'symbol')
  end

  function tokenizer.label()
    get()
    pushToken('label:start')
    ------------------------------------------
    tokenizer.whitespace()
    while alphabet[look()] or digits[look()] do
      get()
    end
    pushToken('label')
    ------------------------------------------
    tokenizer.whitespace()
    if look() == ':' and look(1) == ':' then
      get()
      get()

      pushToken('label:end')
    else
      err('label', '::')
    end
  end

  function tokenizer.operator()
    local operator = look(-1)
    local next = look()

    if arithmetic_operators[operator] and ((opts.extended_assignment and next == '=') or (operator == '/' and next == '/')) then
      get()
    end

    if relational_operators[operator] and next == '=' then
      get()
    end

    pushToken("operator")
  end

  local is = {}

  function is.whitespace(char)
    return whitespace[char]
  end

  function is.comment(char, next)
    return char == '-' and next == '-'
  end

  function is.string(char)
    return char == '\'' or char == '"' or char == '['
  end

  function is.word(char)
    return alphabet[char]
  end

  function is.number(char, next)
    return digits[char] or (char == '.' and digits[next])
  end

  function is.point(char)
    return char == '.'
  end

  function is.label(char, next)
    return char == ':' and next == ':'
  end

  function is.operator(char)
    return operators[char] or char == "#"
  end

  function is.symbol(char)
    return symbols[char]
  end

  while look() ~= '' do
    local char = get()
    local next = look()

    local _ =
        is.whitespace(char) and tokenizer.whitespace() or
        is.comment(char, next) and tokenizer.comment() or
        is.string(char) and tokenizer.string() or
        is.word(char) and tokenizer.word() or
        is.number(char, next) and tokenizer.number() or
        is.point(char) and tokenizer.point() or
        is.label(char, next) and tokenizer.label() or
        is.operator(char) and tokenizer.operator() or
        is.symbol(char) and pushToken('symbol') or
        pushToken('undefined')
  end

  return tokens
end
