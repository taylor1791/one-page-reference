{
  description = "Manages the development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: let
    lib = nixpkgs.lib;
  in {
    # Used by `nix develop`
    devShell = lib.genAttrs lib.systems.flakeExposed (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in pkgs.mkShell {
      buildInputs = with pkgs; [ texlive.combined.scheme-full ];
    });
  };
}
