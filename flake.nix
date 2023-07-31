{
  description = "Introductary presentation about latex";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems = {
      url = "github:nix-systems/x86_64-linux";
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
      packages = {
        handout = pkgs.stdenv.mkDerivation {
          pname = "latex-handout";
          version = "1.0";
          src = ./handout;

          nativeBuildInputs = [
            texlive
          ];

          buildPhase = ''
            latexmk -file-line-error -pdf main.tex
          '';

          installPhase = ''
            install -D main.pdf $out/main.pdf;
          '';
        };
        default = pkgs.stdenv.mkDerivation {
          pname = "latex-presentation";
          version = "1.0";
          src = ./presentation;

          nativeBuildInputs = [
            texlive
          ];

          buildPhase = ''
            latexmk -file-line-error -xelatex main.tex
          '';

          installPhase = ''
            install -D main.pdf $out/main.pdf;
          '';
          FONTCONFIG_FILE = pkgs.makeFontsConf {
            fontDirectories = [
              "${pkgs.fira-mono}/share/fonts/opentype"
              "${pkgs.fira}/share/fonts/opentype"
            ];
          };
        };
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
          texlive
        ];
      };
    });
}
# vim: ts=2

