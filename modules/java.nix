{pkgs, ...}: let
  jdkVersion = "17";

  jdk = pkgs."jdk${jdkVersion}";

  # point gradle to the jdk
  myGradle = pkgs.gradle.override {
    java = jdk;
  };
in {
  home.sessionVariables = {
    JAVA_HOME = "${jdk}/lib/openjdk";
  };

  home.packages = with pkgs; [
    maven
    myGradle
    jdk
  ];

  home.file."jdks/jdk${jdkVersion}".source = jdk;
}
