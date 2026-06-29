# nvim

Neovim config based on [LazyVim](https://github.com/LazyVim/LazyVim) with `neopywal.nvim` colorscheme.

## Structure

| Path | Purpose |
|---|---|
| `init.lua` | Entry point → `require("config.lazy")` |
| `lua/config/lazy.lua` | Lazy.nvim bootstrap + plugin spec |
| `lua/config/options.lua` | Editor options (LazyVim defaults) |
| `lua/config/keymaps.lua` | Disables arrow keys in all modes |
| `lua/config/autocmds.lua` | Autocommands (empty, LazyVim defaults) |
| `lua/plugins/pywal.lua` | neopywal colorscheme plugin |
| `lua/plugins/example.lua` | Example plugin configs (telescope, cmp, treesitter, etc.) |
| `lazy-lock.json` | Lock file — 27 plugins with pinned commits |
| `stylua.toml` | StyLua formatter config (2-space indent, 120 col) |
