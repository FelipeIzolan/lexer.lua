## lexer.lua

![](https://github.com/FelipeIzolan/lexer.lua/assets/80170121/035627cf-f252-4760-b128-73bd6d76cc1e)

## 📝 How to use

The lexer can be loaded with `require()` or `dofile()`. What is returned is a single function.\
This function only takes two argument, which is the source code to lex and the options.

Each token has the following structure:

```lua
{
  type = string, -- one of the token types below
  data = string, -- the source code that makes up the token
  range = { start, end }
}
```

Each token can have one of the following types:

- `string`: The string data between `string:start` and `string:end`.
- `string:start` and `string:end`: starts and ends of a string. There will be no non-string tokens between these two.
- `number`: Numbers, including both base 10 (and scientific notation) and hexadecimal.
- `boolean`: `true` or `false`
- `nil`: `nil`
- `keyword`: Keywords. Like `while`, `end`, `do`, etc.
- `identifier`: Identifier. Variables, function names, etc.
- `symbol`: Symbols, like brackets, parenthesis, ., etc.
- `vararg`: `...`
- `operator`: Operators, like `+`, `-`, `%`, `=`, `==`, `>=`, `<=`, `~=`, `#`, `..`, `//` etc.
- `label`: Basically an `identifier` between a `label:start` and `label:end` or after `goto`.
- `label:start` and `label:end`: The starts and ends of labels. Always equal to `'::'`.
- `whitespace`: ` `, `\n`, `\t` and `\r`.
- `comment`: Basically a `string` between a `comment:start` and `comment:end`.
- `comment:start` and `comment:end`: starts and ends of a comment, `comment:end` can be `]]` or `\n`.
- `undefined`: Anything that isn't one of the above tokens. Consider them errors.

### 🔧 Options

- `comment(boolean)` - Lex comment or not(default=false).
- `whitespace('all'|'newline'|false)` - Lex whitespace or not(default=false).
- `extended_assignment(boolean)` - Lex `+=`, `-=`, `*=`, `/=`, `%=`, `^=` operators, useful for pico-8(default=false).

## 📜 License

- [lexer.lua](https://github.com/FelipeIzolan/lexer.lua) - MIT
- [luaunit](https://github.com/bluebird75/luaunit) - MIT
