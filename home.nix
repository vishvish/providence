{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";
  home.backupFileExtension = "backup";

  programs.home-manager.enable = true;

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
  ];

  programs.zsh = {
    enable = true;
    # Add zsh configuration
  };
}
