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
    flake.robotnixConfigurations.default = robotnix.lib.robotnixSystem ({ pkgs, ... }: {
      flavor = "lineageos";
      device = "marble";
      flavorVersion = "23.0";
      ccache.enable = true;
      # generate with "date +%s"
      buildDateTime = nixpkgs.lib.toIntBase10 (builtins.readFile ./build);
      signing = {
        enable = true;
        # Only used to suppress warnings for test keys
        keyStorePath = "${./keys}";
        buildTimeKeyStorePath = "${./keys}";
      };

      apps.updater = {
        enable = true;
        flavor = "lineageos";
        url = "https://hydra.ani.llc/job/marble/marble/packages.x86_64-linux.default/latest/download/1/marble-otaDir/";
      };
      microg.enable = true;

      # workaround for https://github.com/nix-community/robotnix/issues/354
      product.extraConfig = "PRODUCT_PACKAGE_OVERLAYS += anillc/overlay";
      source.dirs."anillc/overlay".src = let
        url = "https://hydra.ani.llc/job/marble/marble/packages.x86_64-linux.default/latest/download/1/marble-otaDir/lineageos-marble.json";
      in pkgs.runCommand "overlay" {} ''
        VALUES=$out/packages/apps/Updater/app/src/main/res/values
        mkdir -p $VALUES
        cat > $VALUES/strings.xml << EOF
        <?xml version="1.0" encoding="utf-8"?>
        <resources>
            <string name="updater_server_url">${url}</string>
        </resources>
        EOF
      '';
    });
    flake.hydraJobs = { inherit (self) packages; };
  };
}
