{ pkgs ? import <nixpkgs> {} }:
let
  jdk = pkgs.jdk11;

  # point gradle to the jdk
  gradle = pkgs.gradle.override {
    java = jdk;
  };

in pkgs.mkShell {
  buildInputs = [
    jdk
    gradle
  ];
  shellHook = ''
    export JAVA_HOME="${jdk}/lib/openjdk"
  '';
}
