# making godot work with nvim

## lsp setup
this guy does it well, it should work.
this uses basic lspconfig, so it's compatible with a basic minimal vim setup.

https://ask.godotengine.org/122563/how-to-get-the-godot-lsp-to-work-with-nvim-lsp

## theory

instead of starting the language server directly like most lspconfigs do,
we CONNECT to the language server here.
this means on linux, we can netcat into the language server to communicate back and forth.

## godot setup

in godot, set extern editor to /home/zack/Documents/bash/godot_open_nvim.sh, 
where that script is:

```bash
#!/bin/bash

[ -n "$1" ] && file=$1
nvim --server ~/.cache/nvim/godot.pipe --remote-send ':e '$file'<CR>'
```

and set the args to `{file}`

we're opening neovim with it listening to commands through a pipe, so godot will just send the file as the message, 
opening it in neovim (if it's connected to the pipe).

open neovim that connects to godot like:

```bash
nvim --listen ~/.cache/nvim/godot.pipe
```

then we can do really simple IPC between the two.

this requires installing the python neovim-remote module, which you can get from github or pip.
