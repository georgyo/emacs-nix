{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # flake-utils.url = "github:numtide/flake-utils";
    emacs_src = {
      url = "github:janestreet/emacs/emacs-30";
      flake = false;
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs-stable.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
    nix-doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.doomemacs.follows = "doomemacs";
      inputs.emacs-overlay.follows = "emacs-overlay";
    };

  };
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [ "x86_64-linux" ];
        perSystem =
          {
            lib,
            pkgs,
            self',
            ...
          }:
          {
            packages =
              let
                # call this overlay without actually being an overlay, this prevents us from actually initalizing nixpkgs
                doom-overlay = self: inputs.nix-doom-emacs.overlays.default (pkgs // self) { };
                inherit (lib.fix doom-overlay) emacsWithDoom;
              in
              {
                emacs =
                  (pkgs.emacs.overrideAttrs (
                    new: old: {
                      src = pkgs.fetchFromGitHub {
                        owner = "janestreet";
                        repo = "emacs";
                        rev = inputs.emacs_src.rev;
                        hash = inputs.emacs_src.narHash;
                      };
                    }
                  )).override
                    {
                      withCompressInstall = false;
                      srcRepo = true;
                    };
                default = emacsWithDoom {
                  emacs = self'.packages.emacs;
                  extraPackages =
                    epkgs: with epkgs; [
                      lsp-mode
                      treesit-grammars.with-all-grammars
                    ];
                  doomDir = lib.sources.sourceFilesBySuffices inputs.self [ ".el" ];
                  doomLocalDir = "~/.local/share/nix-doom";
                  extraBinPackages = with pkgs; [
                    git
                    fd
                    ripgrep
                    nixd
                  ];
                };

                e = pkgs.callPackage ./e.nix { emacs = self'.packages.default; };
              };
            formatter = pkgs.nixfmt-tree;
          };
      }
    );
}
