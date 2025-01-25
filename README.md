# NVIM AI assistant

🚧 Work in Progress 🚧

AI integration for Neovim. Write, edit, and get AI assistance without leaving nvim.

## Features

- Real-time AI completions using Claude
- Context-aware code suggestions
- Natural language editing commands

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'Antoine-Prieur/nvim-ai-assistant',
    config = function()
        require('claude').setup({
            api_key = 'your_anthropic_api_key',
            model = 'claude-3-sonnet-20240229'
        })
    end
}
```

## Usage

## Configuration
