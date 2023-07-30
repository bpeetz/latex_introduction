{
  description = "Introductary presentation about latex";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # inputs for following
    systems = {
      url = "github:nix-systems/x86_64-linux"; # only evaluate for this system
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs = {
        systems.follows = "systems";
      };
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      texlive = pkgs.texlive.combined.scheme-full;
    in {
      packages.default = pkgs.stdenv.mkDerivation {
        pname = "latex-presentation";
        version = "1.0";
        src = ./.;

        buildInputs = [
          texlive
        ];

        buildPhase = ''
          latexmk -file-line-error main.tex
        '';

        installPhase = ''
          install -D $scr/build/*.pdf $out/;
        '';
      };
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          alejandra
          statix
          ltex-ls
          cocogitto

          texlab
          zathura
        ];
      };
    });
}
# vim: ts=2

