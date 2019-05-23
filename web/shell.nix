{ pkgs ?  import <nixpkgs> { } }:

let

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
    lessc

    script.build
    script.run

    elmPackages.elm
    elmPackages.elm-format

  ];

  shellHook = ''
    HISTFILE=${toString ./.history}
  '';

}

