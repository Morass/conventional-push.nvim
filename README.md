# conventional-push.nvim

A Neovim plugin that provides an interactive interface for making conventional commits with file selection and automatic git push functionality.

## What is this plugin about?

This plugin is designed to **streamline your git workflow** by providing a simple, visual way to:
- **Add** changed files to staging area
- **Commit** with conventional commit messages
- **Push** to remote repository

All in a single, interactive workflow without leaving Neovim. Perfect for developers who want a quick, consistent, and foolproof way to commit and push their changes following conventional commit standards.

## Features

- **Interactive File Selection**: Visual interface to select which changed files to commit
- **Git Status Indicators**: Visual status indicators with colors for file changes:
  - `+` (green) for added files
  - `-` (red) for deleted files
  - `●` (yellow) for modified files
  - `↻` (yellow) for renamed files
  - `©` (yellow) for copied files
  - `?` (white) for untracked files
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

### Conventional Commit Tools
- [telescope-cc.nvim](https://github.com/olacin/telescope-cc.nvim) - Telescope integration for conventional commits
- [cmp-conventionalcommits](https://github.com/davidsierradz/cmp-conventionalcommits) - nvim-cmp source for conventional commit autocomplete
- [Commitizen CLI](https://github.com/commitizen/cz-cli) - Command line tool for conventional commits
- [Commitizen Tools](https://github.com/commitizen-tools/commitizen) - Python tool for conventional commits with version bumping

### General Git Integrations
- [vim-fugitive](https://github.com/tpope/vim-fugitive) - Comprehensive git wrapper for Vim
- [neogit](https://github.com/NeogitOrg/neogit) - Magit clone for Neovim
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) - Lazygit terminal UI integration
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Git decorations and hunk operations

### Key Differences
This plugin focuses specifically on the **Add → Commit → Push** pipeline with an emphasis on:
- Interactive file selection in a popup window
- Built-in conventional commit prefix selection
- Streamlined workflow from file changes to remote push
- No external dependencies (works with just git)

## Requirements

- Neovim 0.5+
- Git installed and configured
- Working git repository
- Terminal with color support (plugin uses cterm colors for visual feedback)

## Important Disclaimers

⚠️ **Hobby Project Warning**: This is a hobby repository created for personal use and learning. While functional, use at your own risk. Always test in a safe environment and ensure you have backups of important work before using this plugin.

⚠️ **Color Compatibility**: This plugin uses cterm colors for highlighting. If you experience visual issues or missing colors, your terminal may not support the color codes used. The plugin should still function, but visual feedback may be limited.

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
- Ensure you're authenticated with your git providermodified
