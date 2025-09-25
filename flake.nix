{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
      inputs.doomemacs.follows = "doomemacs";
      inputs.emacs-overlay.follows = "emacs-overlay";
    };

  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.nix-doom-emacs.overlays.default
          ];
        };
        lib = pkgs.lib;
      in
      {
        packages.default = pkgs.emacsWithDoom {
          emacs = pkgs.emacsNativeComp;
          extraPackages =
            epkgs: with epkgs; [
              lsp-mode
              treesit-grammars.with-all-grammars
            ];
          doomDir = lib.sources.sourceFilesBySuffices self [ ".el" ];
          doomLocalDir = "~/.local/share/nix-doom";
          extraBinPackages = with pkgs; [
            git
            fd
            ripgrep
            nixd
          ];
        };
        formatter = pkgs.nixfmt-tree;
      }
    );
}
