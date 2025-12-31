{
  description = "Providence - Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "git+ssh://git@github.com/vishvish/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, dotfiles }:
    let
      mkHomeConfig = { username, hostname, system }: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit username hostname dotfiles; };
        modules = [
          ./home.nix
          {
            home.username = username;
            home.homeDirectory = "/Users/${username}";
          }
        ];
      };

      # Helper script to change login shell (requires sudo)
      mkChangeShell = system: 
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.writeShellScriptBin "change-shell" ''
          set -euo pipefail
          
          if [ $# -ne 2 ]; then
            echo "Usage: sudo $0 <username> <shell-path>"
            echo "Example: sudo $0 vish ${pkgs.zsh}/bin/zsh"
            exit 1
          fi
          
          USERNAME="$1"
          SHELL_PATH="$2"
          
          # Verify shell exists
          if [ ! -x "$SHELL_PATH" ]; then
            echo "Error: Shell not found or not executable: $SHELL_PATH"
            exit 1
          fi
          
          # Add to /etc/shells if not present
          if ! grep -qxF "$SHELL_PATH" /etc/shells; then
            echo "Adding $SHELL_PATH to /etc/shells..."
            echo "$SHELL_PATH" >> /etc/shells
          else
            echo "$SHELL_PATH already in /etc/shells"
          fi
          
          # Change user shell
          echo "Setting login shell for $USERNAME to $SHELL_PATH..."
          /usr/bin/chsh -s "$SHELL_PATH" "$USERNAME"
          
          echo "Done! Login shell changed to $SHELL_PATH"
        '';

      # Helper script to write /etc/pam.d/sudo_local using the Nix pam_reattach
      mkPamReattach = system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.writeShellScriptBin "setup-pam-reattach" ''
          set -euo pipefail

          if [ "$(id -u)" -ne 0 ]; then
            echo "Please run as root (use sudo)." >&2
            exit 1
          fi

          PAM_LIB="${pkgs.pam-reattach}/lib/pam/pam_reattach.so"
          TARGET="/etc/pam.d/sudo_local"
          BACKUP="$TARGET.bak.$(date +%Y%m%d%H%M%S)"

          if [ -f "$TARGET" ]; then
            cp "$TARGET" "$BACKUP"
            echo "Backed up existing sudo_local to $BACKUP"
          fi

          cat > "$TARGET" <<EOF
auth optional $PAM_LIB
auth sufficient pam_tid.so
EOF

          chmod 644 "$TARGET"
          chown root:wheel "$TARGET" || true

          echo "Updated $TARGET to use Nix pam_reattach at $PAM_LIB"
        '';
    in
    {
      # Helper packages for manual shell setup
      packages.aarch64-darwin.change-shell = mkChangeShell "aarch64-darwin";
      packages.x86_64-darwin.change-shell = mkChangeShell "x86_64-darwin";

      # Helper packages for PAM setup on macOS
      packages.aarch64-darwin.setup-pam-reattach = mkPamReattach "aarch64-darwin";
      packages.x86_64-darwin.setup-pam-reattach = mkPamReattach "x86_64-darwin";

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
