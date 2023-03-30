#!/bin/bash
set -e

# installs intellij Ultimate Linux (dh NOT ARM64) edition

INTELLIJ_VERSION="2023.1"
INTELLIJ_INTERNAL_VERSION="231.8109.175"

# fix missing native libraries error to enable markdown preview in IntelliJ
sudo apt-get install -y libxss1 libatk-bridge2.0-0 libcups2 libxdamage1 libgbm1 libxkbcommon0 libpango-1.0-0 libcairo2

# download and install intellij ultimate manually
mkdir -p $HOME/Downloads/intellij
cd $HOME/Downloads
wget https://download-cdn.jetbrains.com/idea/ideaIU-2023.1.tar.gz
tar xvf ideaIU-${INTELLIJ_VERSION}.tar.gz -C intellij
rm ideaIU-${INTELLIJ_VERSION}.tar.gz

ln -sf "$HOME/Downloads/intellij/idea-IU-${INTELLIJ_INTERNAL_VERSION}/bin/idea.sh" "$HOME/idea.sh"

echo "Finished Installing IntelliJ ${INTELLIJ_INTERNAL_VERSION}"

# evtl. idea64.vmoptions anpassen falls random crashes auftreten:
# -Xmx10000m
# -Xms1024m
