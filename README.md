# A way to compare files and directories

When working with neovim, you may find yourself wanting to compare the current file or directory to
another location that has the same file structure, whether it be on the same computer or on a
different server.

For instance, you might want to compare files in your [Laravel](https://laravel.com/) project to the
project skeleton that you've cloned locally from the
[Laravel GitHub repository](https://github.com/laravel/laravel).

This plugin makes it easy to do this by opening the current file in a new tab and displaying a
side-by-side comparison of the remote file.

## Requirements

[neovim >=0.7.0](https://github.com/neovim/neovim/wiki/Installing-Neovim)

## Install

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use 'aaron-p1/compare-remotes.nvim'
```

## Setup

Minimal setup could look like this:

```lua
require('compare-remotes').setup({
    remotes = {
        -- ['Name shown in selection'] = 'remote absolute path',
        ['My local directory'] = '/path/to/directory/',
        ['My remote directory'] = 'scp://user@server//path/to/directory'
    }
})
```

If you want to change the remotes after setup, you should use the following functions:

```lua
local cr = require('compare-remotes')

local remotes = cr.get_remotes()

cr.set_remotes(remotes)
```

Default setup:

```lua
require('compare-remotes').setup({
    -- List of remotes available remotes for comparison
    remotes = {},
    -- Mapping for comparing the current file
    -- accepts: {key = "<Leader>cr", opts = { "vim.keymap.set()" opts }}
    mapping = nil,
    -- Schemes of buffers that are treated as project files if the path exists
    -- Example: set to {"oil"} if you want to be able to compare directories that are opened
    --          using oil.nvim (https://github.com/stevearc/oil.nvim)
    project_file_schemes = {},
    -- Replace the scheme of the remote path depending on whether it is a file or dir
    -- Example: set dir = {scp = "oil-ssh"} when using oil to be able to compare directories
    --          over ssh
    scheme_replacements = {file = {}, dir = {}}
})
```

## Commands

Commands only get created if the setup function is run.

`:CompareRemotes` - Compares the current file or directory after selecting a remote.

`:CompareRemotes [remote-prefix]` - Compares the current file or directory with remote-prefix.

Example:

`:CompareRemotes scp://user@myserver//var/www/html` - Compares current file with directory
`/var/www/html` on server `myserver`

Note: You could also call the `compare_remotes` function of the lua module.

## Contributing

If you're interested in contributing to this plugin, it's important to note that it's written in
[fennel](https://fennel-lang.org/). The lua code is generated using the fennel transpiler, so all
contributions must also be written in fennel. You can use the command `$ make` to transpile the
code, and before committing any changes, it's mandatory that you use the
[fnlfmt](https://git.sr.ht/~technomancy/fnlfmt) tool by running `$ make format` or using the
[null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) neovim plugin to format the code.

If you're using [nix](https://github.com/NixOS/nix), a package manager for Linux and other Unix
systems, you can easily install the necessary programs for development by running
`$ nix develop`, or by using [direnv](https://github.com/direnv/direnv) with
[nix-direnv](https://github.com/nix-community/nix-direnv).
