{ pkgs ? import <nixpkgs> { } }:
let gdbBinary = "${toString ./.}/target/debug/my-name";
in pkgs.mkShell {

  buildInputs = [
    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt

    pkgs.gdb
    (pkgs.writers.writeBashBin "remote-debugging" ''
      echo "bulid with debug symbols"
      ${pkgs.cargo}/bin/cargo build
      echo "start gdb server to connect"
      ${pkgs.gdb}/bin/gdbserver :1234 ${gdbBinary}
    '')
  ];

}
