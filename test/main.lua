local unit = require('test.luaunit')
local lexer = require('lexer')

local function load_expected(name)
  local src = io.open("./test/expected/" .. name .. ".lua", "r"):read("a")
  local chunk = load(src)

  return chunk and chunk()
end

local function create_test(name, opts)
  local src = io.open("./test/sources/" .. name .. ".lua", "r"):read("a")
  local result = lexer(src, opts)

  unit.assertEquals(result, load_expected(name))

  for _, token in ipairs(result) do
    unit.assertEquals(src:sub(token.posStart, token.posEnd), token.data)
  end
end

TestString = create_test('string')
TestNumber = create_test('number')
TestPoint = create_test('point')
TestLabel = create_test('label')
TestComment = create_test('comment', { comment = true })
TestWhitespace = create_test('whitespace', { whitespace = 'all' })

os.exit(unit.LuaUnit.run())
