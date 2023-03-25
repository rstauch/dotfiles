#!/bin/bash

# ACHTUNG: Script aktuell nicht getestet!

set -e

INTELLIJ_VERSION="2022.3.3"
INTELLIJ_INTERNAL_VERSION="223.8836.41"

# fix missing native libraries error to enable markdown preview in IntelliJ
sudo apt-get install -y libxss1 libatk-bridge2.0-0 libcups2 libxdamage1 libgbm1 libxkbcommon0 libpango-1.0-0 libcairo2

# download and install intellij ultimate manually
mkdir -p $HOME/Downloads/intellij
cd $HOME/Downloads
wget https://download-cdn.jetbrains.com/idea/ideaIU-${INTELLIJ_VERSION}.tar.gz
xvf ideaIU-${INTELLIJ_VERSION}.tar.gz -C intellij
rm *.tar.gz

sh $HOME/Downloads/intellij/idea-IU-${INTELLIJ_INTERNAL_VERSION}/bin/idea.sh

# evtl. idea64.vmoptions anpassen falls random crashes auftreten:
# -Xmx10000m
# -Xms1024m
