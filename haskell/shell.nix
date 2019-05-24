{ pkgs ?  import <nixpkgs> { } }:

let

  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};

  script = {
    build = pkgs.writeShellScriptBin "build" /* sh */ ''
      echo "this could be your buildscript"
    '';
    run = pkgs.writeShellScriptBin "run" /* sh */ ''
      echo "this could be your run script"
    '';
  };

in pkgs.mkShell {

  buildInputs = with pkgs; [
    script.build
    script.run

    # common tools
    # ------------
    cabal2nix
    cabal-install

    stylish-cabal
    haskellPackages.stylish-haskell
    haskellPackages.hoogle

    # automatically create CI scripts
    # https://github.com/haskell-CI/haskell-ci#quick-start-instructions
    haskell-ci

    # IDE setups
    # ----------

    # VSCode hde setup
    # https://github.com/haskell/haskell-ide-engine#using-vs-code-with-nix
    (pkgs.vscode.overrideDerivation (old: {
      postFixup = ''
        wrapProgram $out/bin/code --prefix PATH : ${lib.makeBinPath [
          # Install stable HIE for GHC 8.6.4 (multiple ghc versions are allowed)
          (all-hies.selection { selector = p: { inherit (p) ghc864; }; })
        ]}
      '';
    }))

  ];

  shellHook = ''
    HISTFILE=${toString ./.history}
  '';

}
