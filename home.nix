{ config, pkgs, lib, dotfiles, ... }:

{
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Ensure nix profile bins precede Homebrew in PATH
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
    "${pkgs.gawk}/bin"
    "/usr/bin"
    "/bin"
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
    gawk
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

  # Just install zsh as a package - we manage config via dotfiles
  # programs.zsh is disabled to avoid conflicts with our custom dotfiles

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

  # Set login shell to the Nix-provided zsh (macOS)
  # 1. Add zsh to /etc/shells if not present
  # 2. Use chsh to set as login shell
  home.activation.setLoginShell = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ZSH_PATH="${pkgs.zsh}/bin/zsh"
    
    # Add to /etc/shells if not already there
    if ! /bin/cat /etc/shells | /usr/bin/grep -q "^$ZSH_PATH$"; then
      echo "Adding $ZSH_PATH to /etc/shells (sudo required)..."
      echo "$ZSH_PATH" | /usr/bin/sudo /usr/bin/tee -a /etc/shells >/dev/null
    fi
    
    # Set login shell if different
    CURRENT=$(/usr/bin/dscl . -read /Users/"$USER" UserShell 2>/dev/null | /usr/bin/cut -d' ' -f2)
    if [ "$CURRENT" != "$ZSH_PATH" ]; then
      echo "Setting login shell to $ZSH_PATH..."
      /usr/bin/chsh -s "$ZSH_PATH"
    fi
  '';
}
