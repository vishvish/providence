# Providence - Home Manager Configuration

A Nix flake-based home-manager configuration for bootstrapping macOS machines.

## Quick Start (No pre-installation needed)

Bootstrap your machine directly from this flake without installing home-manager first:

```bash
nix --extra-experimental-features 'nix-command flakes' run --no-write-lock-file github:vishvish/providence#homeConfigurations.vish@hobbes.activationPackage
```

For `hobbes-x` (Intel Mac):

```bash
nix --extra-experimental-features 'nix-command flakes' run --no-write-lock-file github:vishvish/providence#homeConfigurations.vish@hobbes-x.activationPackage
```

Existing `.zshrc` and `.zshenv` will be backed up once to `.backup` before linking.

## Local Bootstrap (from cloned repo)

```bash
home-manager switch --flake .#vish@hobbes
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

## Touch ID for sudo (Nix pam_reattach)

Use the Nix-built helper to install `pam_reattach` into `/etc/pam.d/sudo_local` and keep Homebrew out of the PAM chain:

```bash
# Build the helper (pick the right arch: aarch64-darwin or x86_64-darwin)
nix build .#packages.aarch64-darwin.setup-pam-reattach

# Apply to /etc/pam.d/sudo_local (makes a timestamped backup first)
sudo ./result/bin/setup-pam-reattach

# Sanity-check sudo/Touch ID
sudo -n true
```

The helper writes two lines to `/etc/pam.d/sudo_local`:
- `auth optional <nix-store>/lib/pam/pam_reattach.so`
- `auth sufficient pam_tid.so`

Re-run the helper after updating `nixpkgs` so the sudo stack points at the current Nix store path.

## Faster dotfiles + home-manager switch

Use the helper to prefer a local dotfiles checkout when it is ahead of the pinned flake input:

```bash
./bin/hm-switch                         # defaults to vish@hobbes
HM_CONFIG=vish@hobbes-x ./bin/hm-switch  # pick another host
```

Behavior:
- If `$HOME/git/system/dotfiles` exists, contains the pinned `dotfiles` rev, and is ahead of it, the helper runs `home-manager switch` with `--override-input dotfiles path:$HOME/git/system/dotfiles`.
- Otherwise it falls back to the pinned `dotfiles` input from `flake.lock`.

To update the pin after pushing dotfiles:
```bash
nix flake lock --update-input dotfiles
```


## Using local dotfiles quickly

Two common workflows are supported: fast iteration via `hm-switch`, and an optional instant-edit approach using symlinks for files you prefer to edit live.

- Fast iteration with `hm-switch` (recommended):

   1. Edit files inside your local dotfiles repo (example path shown below).
   2. Commit the change locally (no push required):

       ```bash
       cd ~/git/system/dotfiles
       # edit e.g. .zshrc
       git add .zshrc
       git commit -m "wip: tweak zsh prompt for testing"
       ```

   3. Run the helper from the `providence` repo to apply your local commit:

       ```bash
       # from the repo root
       ./bin/hm-switch

       # or absolute path
       /Users/vish/git/system/providence/bin/hm-switch
       ```

   Notes:
   - `hm-switch` uses the local repo's `HEAD` commit and passes a `git+file://...` URI to `home-manager`. Uncommitted changes will NOT be picked up—you must commit locally first.
   - No remote push is required to test changes; pushing is only necessary when you want to update the remote and the pinned flake input.

- Instant edits without running `hm-switch` (optional):

   If you want edits to take effect immediately (for example, shell config like `.zshrc`), you can symlink that file directly from your dotfiles repo into your $HOME and remove it from home-manager management.

   ```bash
   ln -sf ~/git/system/dotfiles/.zshrc ~/.zshrc
   ```

   Then edit your home-manager config to stop managing that file (remove or comment the `home.file.".zshrc"` entry), and run a single `home-manager switch` to ensure there's no conflict:

   ```bash
   home-manager switch --flake ".#vish@hobbes"
   ```

   Warning: if a file is still managed by home-manager, it may be overwritten on the next `home-manager switch`. Use this approach only for files you explicitly want to keep outside of home-manager control.

Both approaches are useful: prefer `hm-switch` for reproducible, managed dotfiles and use symlinks for rapid, local-only iteration when you need immediate feedback.

## License

This repository is licensed under the Creative Commons Attribution-ShareAlike 4.0 International
(CC BY-SA 4.0). See the [LICENSE](LICENSE) file for the full legal text and details on how
to attribute and redistribute derivative works.

