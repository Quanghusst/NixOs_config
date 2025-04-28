# ONLY FILE `home.nix` for nix configuration 

1. Install **Home manager**
```bash
sudo nix-channel --remove home-manager
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
sudo nix-channel --update
sudo nixos-rebuild switch
```
2. Replace file `home.nix` 

> NOTE version of Nixpkgs and Home-manager is same
