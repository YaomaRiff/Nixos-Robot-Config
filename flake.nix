{
  description = "Traversal's Raspberry Pi (robot)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }: {
    # Raspberry Pi 4 定制 SD 镜像（aarch64），在 x86_64 构建机上交叉构建
    # 构建机需要：boot.binfmt.emulatedSystems = [ "aarch64-linux" ]
    nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ./rpi4.nix
      ];
    };
  };
}
