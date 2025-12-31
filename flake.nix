{
  description = "Providence - Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      mkHomeConfig = { username, hostname, system }: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit username hostname; };
        modules = [
          ./home.nix
          {
            home.username = username;
            home.homeDirectory = "/Users/${username}";
          }
        ];
      };
    in
    {
      homeConfigurations = {
        "vish@hobbes" = mkHomeConfig {
          username = "vish";
          hostname = "hobbes";
          system = "aarch64-darwin";
        };

        "vish@hobbes-x" = mkHomeConfig {
          username = "vish";
          hostname = "hobbes-x";
          system = "x86_64-darwin"; 
        };

        # Template for new machines:
        # "username@hostname" = mkHomeConfig {
        #   username = "username";
        #   hostname = "hostname";
        #   system = "aarch64-darwin";  # or x86_64-darwin for Intel
        # };
      };
    };
}
