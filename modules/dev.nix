{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    jq
    just
    shellcheck

    # Make JSON greppable, https://github.com/tomnomnom/gron
    gron

    # Terminal JSON viewer, https://github.com/antonmedv/fx
    fx

    # Run SQL directly on CSV or TSV files, https://github.com/harelba/q
    q-text-as-data

    # Render markdown on the CLI, https://github.com/charmbracelet/glow
    glow

    # A generic non-JVM producer and consumer for Apache Kafka, https://github.com/edenhill/kcat
    # kcat
  ];
}
