# conventional-push.nvim

A Neovim plugin that provides an interactive interface for making conventional commits with file selection and automatic git push functionality.

## Features

- **Interactive File Selection**: Visual interface to select which changed files to commit
- **Conventional Commits**: Built-in support for conventional commit prefixes
- **User-Friendly Interface**: Navigate with vim-like keybindings
- **Automatic Push**: Option to push commits immediately after creation
- **Customizable Prefixes**: Configure your own conventional commit prefixes
- **Git Repository Detection**: Automatically detects if you're in a git repository
- **Error Handling**: Clear error messages for common issues

## Installation

### Using vim-plug

For a private repository, add this to your `~/.vimrc` or `~/.config/nvim/init.vim`:

```vim
Plug 'https://github.com/yourusername/conventional-push.nvim'
```

### Using packer.nvim

```lua
use {
  'yourusername/conventional-push.nvim',
  config = function()
    require('conventional-push').setup()
  end
}
```

### Using lazy.nvim

```lua
{
  'yourusername/conventional-push.nvim',
  config = function()
    require('conventional-push').setup()
  end
}
```

## Usage

### Basic Usage

1. Open any file in a git repository
2. Run the command `:ConventionalPush`
3. Follow the interactive prompts:
   - **File Selection**: Select files to commit using `a` (add), `d` (deselect), `t` (toggle)
   - **Confirmation**: Review your selected files
   - **Prefix Selection**: Choose a conventional commit prefix
   - **Message Input**: Enter your commit message
   - **Push Confirmation**: Choose whether to push immediately

### Keybindings

#### File Selection Screen
- `j/k` - Navigate up/down
- `a` - Add/select current file
- `d` - Deselect current file
- `t` - Toggle selection of current file
- Navigate to "Select All" and press `a` or `t` to select all files
- `Enter` - Continue to next screen
- `q` - Quit

#### Confirmation Screen
- `Enter` - Continue to prefix selection
- `q` - Go back to file selection

#### Prefix Selection Screen
- `j/k` - Navigate up/down
- `Enter` - Select prefix and continue
- `q` - Go back to confirmation

#### Message Input Screen
- Type your commit message after the prefix
- `Enter` - Create commit and continue
- `Esc` - Go back to prefix selection

#### Push Confirmation Screen
- `j/k` - Navigate between Yes/No
- `Enter` - Confirm selection
- No `q` option (you must choose Yes or No)

#### Final Summary Screen
- `Enter` - Close the plugin

## Configuration

### Default Configuration

The plugin comes with sensible defaults, but you can customize it:

```lua
require('conventional-push').setup({
  prefixes = {'chore', 'fix', 'docs', 'feat', 'test', 'refactor', 'style', 'build', 'perf', 'debug', 'ci', 'revert', 'merge'}
})
```

### Using Vim Script

You can also configure the prefixes using vim script in your `~/.vimrc`:

```vim
let g:conventional_push_prefixes = ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore']
```

### Conventional Commit Prefixes

The default prefixes follow conventional commit standards:

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools and libraries
- **build**: Changes that affect the build system or external dependencies
- **perf**: A code change that improves performance
- **debug**: Temporary commits for debugging purposes
- **ci**: Changes to CI configuration files and scripts
- **revert**: Reverts a previous commit
- **merge**: Merge commits

## How It Works

1. **Repository Check**: Verifies you're in a git repository
2. **File Detection**: Uses `git status --porcelain` to find changed files
3. **Interactive Selection**: Presents files in a popup window with selection interface
4. **Validation**: Ensures at least one file is selected before proceeding
5. **Prefix Selection**: Shows configured conventional commit prefixes
6. **Message Input**: Allows entering commit message with prefix pre-filled
7. **Git Operations**: Executes `git add`, `git commit`, and optionally `git push`
8. **Push Handling**: Automatically handles first-time pushes with upstream setup

## Error Handling

The plugin provides clear error messages for common scenarios:

- Not in a git repository
- No changed files found
- No files selected
- Empty commit message
- Git command failures

## Similar Projects

- [vim-fugitive](https://github.com/tpope/vim-fugitive) - Comprehensive git integration for Vim
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) - Lazygit integration for Neovim
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Git integration with signs and hunks
- [neogit](https://github.com/TimUntersberger/neogit) - Magit clone for Neovim

## Requirements

- Neovim 0.5+
- Git installed and configured
- Working git repository

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

## Troubleshooting

### Plugin doesn't load
- Ensure you're using Neovim 0.5 or later
- Check that the plugin is properly installed
- Verify your configuration syntax

### Git operations fail
- Ensure you're in a git repository
- Check that git is properly configured
- Verify you have necessary permissions for the repository

### No files detected
- Make sure you have uncommitted changes
- Check that `git status` shows changed files
- Ensure you're in the correct directory

### Push fails
- Verify you have push permissions to the remote repository
- Check your git remote configuration
- Ensure you're authenticated with your git provider