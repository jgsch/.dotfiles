
add `git` and `nix.settings.experimental-features = [ "nix-command" "flakes" ];` in /etc/nixos/configuration.nix

```bash
nmtui
```

```bash
nix-shell -p git
cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/.config/nix/hosts/desktop/hardware-configuration.nix
git add -A
sudo nixos-rebuild switch --flake ~/.dotfiles/.config/nix#desktop
```

```bash
cd ~/.dotfiles
stow .
```
