Personal NeoVim 0.5 configuration
=================================

This is a 100% Lua Neovim 0.5 configuration. The content of this repository is
expected to be located in `$HOME/.config/nvim`

## Requirements
* [packer.nvim] A Neovim package manager.
* [rust-analyzer] is expected to be in `$PATH`
* [ripgrep]
* [gopls] expected to be in `$PATH`. Don't trust the docs, NeoVim won't install it for you.
* [omnisharp]: A standalone (with mono embedded) omnisharp server is expected in `/home/yoeight/omnisharp-mono`
  LSP doesn't expend `~` or `$HOME` so if you want a different location, change `lua/lsp.lua` omnisharp `cmd` property.

## Personal notes
* If LSP doesn't seem to work, you probably didn't start NeoVim at the root of your project.

[packer.nvim]: https://github.com/wbthomason/packer.nvim#quickstart
[rust-analyzer]: https://rust-analyzer.github.io/manual.html#installation
[ripgrep]: https://github.com/BurntSushi/ripgrep#installation
[omnisharp]: https://github.com/OmniSharp/omnisharp-roslyn/releases
[gopls]: https://github.com/golang/tools/tree/master/gopls

