{ config, pkgs, lib, dotfiles, ... }:

{
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Ensure nix profile bins precede Homebrew in PATH
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
    "/opt/homebrew/bin"
  ];

  home.packages = with pkgs; [
    # CLI tools and utilities
    ack
    atuin
    bat
    bottom
    ctags
    d2
    deno
    direnv
    duf
    dust
    delta
    eza
    exiftool
    figlet
    fortune
    gh
    git
    git-extras
    git-filter-repo
    gitleaks
    gping
    lazygit
    lolcat
    magic-wormhole
    macchina
    mc
    mkcert
    nmap
    pandoc
    pgcli
    rename
    ripgrep
    shellcheck
    starship
    tokei
    tree
    tor
    wget
    wtfutil
    yazi
    yq
    zoxide
    zsh
    zsh-completions

    # Development tools
    autoconf
    automake
    bison
    cmake
    docutils
    doxygen
    flex
    gcc-arm-embedded
    gobject-introspection
    graphviz
    jq
    luarocks
    ninja
    pkg-config
    python3
    tree-sitter

    # Languages and runtimes
    go
    llvm
    neovim
    nodejs
    pnpm
    uv

    # Database and data tools
    postgresql_16
    visidata

    # Media and graphics
    ffmpeg
    imagemagick
    vips

    # Games
    nethack

    # Other tools
    fzf
    curl
    unzip

    # Nix tooling / LSP
    nixd
    alejandra
    statix
    deadnix
  ];

  programs.zsh = {
    enable = true;
    # Add zsh configuration
  };

  # Link dotfiles from private repo
  # Example: uncomment and customize based on your dotfiles structure
  # home.file.".gitconfig".source = "${dotfiles}/.gitconfig";
  # home.file.".config/nvim/init.vim".source = "${dotfiles}/.config/nvim/init.vim";

  # Back up existing zsh dotfiles once, before links are created
  home.activation.backupZshDotfiles = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    for f in .zshrc .zshenv; do
      if [ -e "$HOME/$f" ] && [ ! -e "$HOME/$f.backup" ]; then
        echo "Backing up $HOME/$f to $HOME/$f.backup"
        mv "$HOME/$f" "$HOME/$f.backup"
      fi
    done
  '';
}
