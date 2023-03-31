{pkgs, ...}: let

in {
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
    # required for intellij to work
    # ggf. VcXsrv neustarten wenn artifakte auftrreten
    # funktioniert aktuell am besten mit via manuell installierten intellij
    _JAVA_OPTIONS = "-Xmx10000M -Dremote.x11.workaround=false -Dsun.java2d.metal=false";
  };

  home.packages = with pkgs; [
    maven
    gradle
    jdk17
  ];

  home.file."jdks/jdk17".source = pkgs.jdk17;
}
