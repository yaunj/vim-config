# vim-config

Personal vim config. Uses Vundle to manage plugins.

Initialize submodules and install with GNU stow:

```
git submodule init
git submodule update
stow -R -t ~ --ignore README.md .
vim +BundleInstall +qall
```
