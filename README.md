

## Partitions

Partition EFI: 1 Go, FAT32, /boot, flag boot
Partition root:  btrfs,  /, Encrypt (LUKS)

## Nixos

```
nmtui

nix-shell -p git 
git clone https://github.com/jgsch/.dotfiles
sudo nixos-generate-config --show-hardware-config > ~/.dotfiles/.config/nix/hardware-configuration.nix

sudo nixos-rebuild switch --flake /home/jg/.dotfiles/.config/nix#laptop
```

## Dotfiles

```
cd ~/.dotfiles
stow .
```

## Herdr plugins

```
nix shell nixpkgs#cargo nixpkgs#rustc -c herdr plugin install willfish/herdr-navigator
```
