# dotfiles

## Inspriation

- https://github.com/donovanglover/nix-config
- https://github.com/Misterio77/nix-starter-configs

## MacOS Instructions

1. [Install NixOS](https://nixos.org/download/#nix-install-macos)
2. [Install homebrew](https://brew.sh/)
3. Run `just switch`


## Useful commands

If fonts are broken after update, resseting the font cache might help:
```bash
# found here: https://github.com/nix-community/home-manager/issues/6160#issuecomment-2510227909
fc-cache -rv
```

## Full Disk Encryption

### Encrypt Post-Installation

These commands can be run in a live boot to encrypt the nixos partition post install.

```bash
# figure the target partition's name
lsblk

# encrypt partition in place
cryptsetup reencrypt --encrypt --type luks2 --reduce-device-size 32m /dev/nvme0n1p2

# decrypt partition
udisksctl unlock -b /dev/nvme0n1p2

# repair file system
sudo e2fsck -f /dev/dm-0
sudo resize2fs /dev/dm-0

# mount partition
udisksctl mount -b /dev/dm-0 

# get disk label for nix config (this should be the actual partition to decrypt on startup)
ls -al /dev/disk/by-uuid

# enter into nixos for repairs
sudo mount -o /dev/nvme0n1 /mnt
sudo mount /dev/nvme0n1p1 /run/media/nixos/9cac955d-cc10-4f2e-bb51-2227995c344b/boot
sudo nixos-enter --root /run/media/nixos/9cac955d-cc10-4f2e-bb51-2227995c344b/
```

#### Useful resources:
- https://www.man7.org/linux/man-pages/man8/cryptsetup-reencrypt.8.html#EXAMPLES
- https://superuser.com/questions/216879/encrypt-an-existing-partition-in-linux-while-preserving-its-data
- https://gist.github.com/walkermalling/23cf138432aee9d36cf59ff5b63a2a58
