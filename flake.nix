{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:matthewcroughan/nixpkgs/mc/riscv-testing";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs@{ flake-parts, self, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
          packages.p550-image = self.nixosConfigurations.p550.config.system.build.image.overrideAttrs {
            postFixup = ''
              ${inputs.nixpkgs.legacyPackages.x86_64-linux.zstd}/bin/zstd --compress --rm $out/image.raw
            '';
          };
      };
      flake = {
        nixosConfigurations.p550 = inputs.nixpkgs.lib.nixosSystem {
#          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            "${nixpkgs}/nixos/modules/profiles/minimal.nix"
            ./p550.nix
            ./configuration.nix
            ./repart.nix
          ];
        };
      };
    };
}
