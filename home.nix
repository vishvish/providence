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
    package = pkgs.zsh;          # use Nix-provided zsh
  };

  # Link dotfiles from private repo
  home.file = {
    # Top-level dotfiles
    ".gitconfig".source = "${dotfiles}/gitconfig";
    ".gitignore".source = "${dotfiles}/gitignore";
    ".vimrc".source = "${dotfiles}/vimrc";
    ".tmux.conf".source = "${dotfiles}/tmux.conf";
    ".tmux-powerlinerc".source = "${dotfiles}/tmux-powerlinerc";
    ".digrc".source = "${dotfiles}/digrc";
    ".tigrc".source = "${dotfiles}/tigrc";
    
    # Zsh config
    ".zshenv".source = "${dotfiles}/zshenv";
    ".zshrc".source = "${dotfiles}/zshrc";
    ".zprofile".source = "${dotfiles}/zprofile";
    ".zlogin".source = "${dotfiles}/zlogin";
    ".zsh".source = "${dotfiles}/zsh"; # zsh functions and scripts

    # Bash config for those annoying apps that still use bash
    ".bashrc".source = "${dotfiles}/bashrc";
    ".bash_profile".source = "${dotfiles}/bash_profile";

    # Fortunes
    ".fortunes".source = "${dotfiles}/fortunes";
    
    # I do like a good binary directory
    ".bin".source = "${dotfiles}/bin";

    # Time for ssh configs
    ".ssh/config".source = "${dotfiles}/ssh/config";


    # Add more as needed:
    # ".config/helix".source = "${dotfiles}/config/helix";
    # ".config/kitty".source = "${dotfiles}/config/kitty";
    # ".aws/config".source = "${dotfiles}/aws/config";
  };

  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";

  # Set login shell to the Nix-provided zsh using dscl (macOS)
  home.activation.setLoginShell = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    /usr/bin/dscl . -create /Users/vish UserShell ${pkgs.zsh}/bin/zsh
  '';
}
