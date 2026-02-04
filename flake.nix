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
      ccache.enable = true;
      # generate with "date +%s"
      buildDateTime = nixpkgs.lib.toIntBase10 (builtins.readFile ./build);
      signing = {
        enable = true;
        keyStorePath = "/var/secrets/marble-keys/keys";
      };

      apps.updater = {
        enable = true;
        flavor = "lineageos";
        url = "https://hydra.ani.llc/job/marble/marble/packages.x86_64-linux.default/latest/download/1/marble-otaDir/";
      };
      microg.enable = true;
    };
    flake.hydraJobs = { inherit (self) packages; };
  };
}
