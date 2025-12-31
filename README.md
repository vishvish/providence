# Providence - Home Manager Configuration

A Nix flake-based home-manager configuration for bootstrapping macOS machines.

## Quick Start (No pre-installation needed)

Bootstrap your machine directly from this flake without installing home-manager first:

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh --no-write-lock-file github:vishvish/providence#homeConfigurations.vish@hobbes.activationPackage
```

For `hobbes-x` (Intel Mac):

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh --no-write-lock-file github:vishvish/providence#homeConfigurations.vish@hobbes-x.activationPackage
```

Existing `.zshrc` and `.zshenv` will be backed up once to `.backup` before linking.

From GitHub:

```bash
nix --extra-experimental-features 'nix-command flakes' run --no-write-lock-file github:vishvish/providence#homeConfigurations.vish@hobbes.activationPackage
```

## After Initial Bootstrap

Once applied, you can use home-manager directly:

```bash
home-manager switch --flake ".#vish@hobbes"
```

## Adding New Machines

1. Add your configuration to `flake.nix` in the `homeConfigurations` section:
   ```nix
   "username@hostname" = mkHomeConfig {
     username = "username";
     hostname = "hostname";
     system = "aarch64-darwin";  # or x86_64-darwin for Intel Mac
   };
   ```

2. Run the activation package:
   ```bash
   nix --extra-experimental-features 'nix-command flakes' run .#homeConfigurations.username@hostname.activationPackage
   ```

## Managing Packages

Edit `home.nix` to add/remove packages. All packages are listed in `home.packages`.

## Update Dependencies

```bash
nix flake update
home-manager switch --flake ".#vish@hobbes"
```

