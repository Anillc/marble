{
  inputs.robotnix.url = "github:nix-community/robotnix";
  outputs = inputs@{
    self, nixpkgs, flake-parts, robotnix,
  }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, ... }: {
      packages.default = self.robotnixConfigurations.default.otaDir;
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [];
        nativeBuildInputs = with pkgs; [];
      };
    };
    flake.robotnixConfigurations.default = robotnix.lib.robotnixSystem {
      flavor = "lineageos";
      device = "marble";
      flavorVersion = "23.0";
      microg.enable = true;
      ccache.enable = true;
    };
    flake.hydraJobs = { inherit (self) packages; };
  };
}
