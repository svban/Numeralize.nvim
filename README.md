# Numeralize.nvim

Numeralize.nvim is a Neovim plugin that converts numbers in your text to their corresponding words or Roman numerals. This plugin allows you to easily convert numbers in a specified pattern to either English words or Roman numerals within your Neovim buffer.

## Features
- Convert numbers to English words
- Supports both cardinal and ordinal numbers
- Convert numbers to Roman numerals
- Supports custom patterns for matching numbers

## Installation
### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    'svban/numeralize.nvim',
    opts={},
    cmd={"NumbersToWords", "NumbersToRoman"}
}
```
- an external library is required, it will be automatically installed, but if it doesn't for some reason, you can use `pip3 install num2words`

## Usage
### Convert Numbers to Words
To convert numbers to words, use the following command:
``` vim
:NumbersToWords p<pattern> [c|o]
```
- p<pattern>: Specifies the pattern to match numbers. Prefix the pattern with p.
- [c|o]: Optional. Specifies the conversion type. Use c for cardinal (default) or o for ordinal.

### Convert Numbers to Roman numerals
To convert numbers to Roman numerals, use the following command:
```vim
:NumbersToRoman p<pattern>
```
- p<pattern>: Specifies the pattern to match numbers. Prefix the pattern with p.

### Examples

To convert all numbers in the buffer to words:
```vim
:NumbersToWords p\d\+ c
```

To convert all numbers in the buffer to Roman numerals:
```vim
:NumbersToRoman p\d\+
```

## Inspirations
- [inkarkat/NumberToEnglish](https://github.com/inkarkat/NumberToEnglish)
