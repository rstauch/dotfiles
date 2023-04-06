{pkgs ? import <nixpkgs> {}}: let
  jdk = pkgs.jdk17;

  # point gradle to the jdk
  gradle = pkgs.gradle.override {
    java = jdk;
  };

  graalvm = pkgs.graalvm17-ce;
in
  pkgs.mkShell {
    buildInputs = [
      jdk
      gradle
      graalvm
    ];
    shellHook = ''
      export JAVA_HOME="${jdk}/lib/openjdk"
      export GRAALVM_HOME="${graalvm}"
    '';
  }
