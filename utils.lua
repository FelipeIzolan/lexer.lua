function lookupify(src)
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

alphabet = lookupify('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_')
whitespace = lookupify('\n\t\r ')

digits = lookupify('0123456789')
hex_digits = lookupify('0123456789abcdefABCDEF')
scientific_digits = lookupify(".Ee+-")

symbols = lookupify("[]{}():;,")
operators = lookupify('+-*/%^~=><')
arithmetic_operators = lookupify('+-*/%^')
relational_operators = lookupify('~=><')

keywords = {
  structure = lookupify({
    'and', 'break', 'do', 'else', 'elseif', 'end', 'for', 'function',
    'goto', 'if', 'in', 'local', 'not', 'or', 'repeat', 'return', 'then',
    'until', 'while'
  }),

  value = lookupify({
    'true', 'false', 'nil'
  })
}
