#!/bin/bash

# ACHTUNG: Script aktuell nicht getestet!

set -e

INTELLIJ_VERSION="2022.3.3"
INTELLIJ_INTERNAL_VERSION="223.8836.41"

# fix missing native libraries error to enable markdown pre-view in IntelliJ
sudo apt-get install -y libxss1 libatk-bridge2.0-0 libcups2 libxdamage1 libgbm1 libxkbcommon0 libpango-1.0-0 libcairo2

# download and install intellij ultimate manually
mkdir -p ~/Downloads/intellij
cd  ~/Downloads
wget https://download-cdn.jetbrains.com/idea/ideaIU-${INTELLIJ_VERSION}.tar.gz
xvf ideaIU-${INTELLIJ_VERSION}.tar.gz -C intellij

sh ~/Downloads/intellij/idea-IU-${INTELLIJ_INTERNAL_VERSION}/bin/idea.sh

# evtl. idea64.vmoptions anpassen falls random crashes auftreten:
# -Xmx10000m
# -Xms1024m

# login into intellij ultimate with account
# enable settings sync: pull settings from account
# setting: Enable stating area
# evtl. setting: store passwords in keepass aktivieren
# login into copilot via Tools -> Copilot -> login to Github

# bei seltsamen problemen (ui-glitches, copy/paste funktioniert nicht, etc.) kann es helfen, VcXsrv neuzustarten
