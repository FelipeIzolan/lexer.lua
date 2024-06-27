![](https://github.com/FelipeIzolan/lexer.lua/assets/80170121/035627cf-f252-4760-b128-73bd6d76cc1e)

## 📝 How to use

The lexer can be loaded with `require()` or `dofile()`. What is returned is a single function.\
This function only takes two argument, which is the source code to lex and the options.

Each token has the following structure:

```lua
{
  type = string, -- one of the token types below
  data = string, -- the source code that makes up the token
  posStart = number, -- the position (inclusive) within that line that the token starts
  posEnd = number -- the position (inclusive) within that line that the token ends
}
```

Each token can have one of the following types:

- `string:start` and `string:end`: starts and ends of a string. There will be no non-string tokens between these two.
- `string`: The string data between `string:start` and `string:end`.
- `number`: Numbers, including both base 10 (and scientific notation) and hexadecimal.
- `boolean`: `true` or `false`
- `nil`: `nil`
- `keyword`: Keywords. Like `while`, `end`, `do`, etc.
- `identifier`: Identifier. Variables, function names, etc.
- `symbol`: Symbols, like brackets, parenthesis, ., etc.
- `vararg`: `...`
- `operator`: Operators, like `+`, `-`, `%`, `=`, `==`, `>=`, `<=`, `~=`, `#`, `..`, `//` etc.
- `label:start` and `label:end`: The starts and ends of labels. Always equal to `'::'`.
- `label`: Basically an `identifier` between a `label:start` and `label:end`.
- `newline`: `\n`.
- `whitespace`: ` `, `\t` and `\r`.
- `undefined`: Anything that isn't one of the above tokens. Consider them errors.

### 🔧 Options

- `newline(boolean)` - Lex newline or not (default=false).
- `whitespace(boolean)` - Lex whitespace or not (default=false).
- `extended_assignment(boolean)` - Lex `+=`, `-=`, `*=`, `/=`, `%=`, `^=` operators, useful for pico-8 (default=false).

## 📜 License

- [lexer.lua](https://github.com/FelipeIzolan/lexer.lua) - MIT
- [busted](https://github.com/lunarmodules/busted) - MIT
