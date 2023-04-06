{pkgs ? import <nixpkgs> {}}: let
  jdk = pkgs.jdk11;

  # point gradle to the jdk
  gradle = pkgs.gradle.override {
    java = jdk;
  };

  graalvm = pkgs.graalvm11-ce;
in
  pkgs.mkShell {
    buildInputs = [
      graalvm
      jdk
      gradle
    ];
    shellHook = ''
      export JAVA_HOME="${jdk}/lib/openjdk"
      export GRAALVM_HOME="${graalvm}"
    '';
  }
