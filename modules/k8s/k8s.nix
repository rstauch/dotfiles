{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    minikube
    kubectl
    kubernetes-helm
    # kubectx, https://github.com/ahmetb/kubectx
    # k9s
    kubeshark
  ];
}
