{pkgs, ...}: let
  # avoid collisions
  jdk11-low = pkgs.jdk11.overrideAttrs (oldAttrs: {
    meta.priority = 10;
  });
in {
  home.sessionVariables = {
    JAVA_11_HOME = "${jdk11-low}/lib/openjdk";
    JAVA_17_HOME = "${pkgs.jdk17}/lib/openjdk";
#    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
    JAVA_HOME = "${pkgs.jdk11}/lib/openjdk";

    # required for intellij to work
    # ggf. VcXsrv neustarten wenn artifakte auftrreten
    # funktioniert aktuell am besten mit via manuell installierten intellij
    _JAVA_OPTIONS = "-Xmx10000M -Dremote.x11.workaround=false -Dsun.java2d.metal=false";
  };

  home.packages = with pkgs; [
    maven
    gradle
    jdk11-low
    jdk17
  ];

  home.file."jdks/jdk11".source = jdk11-low;
  home.file."jdks/jdk17".source = pkgs.jdk17;
}
