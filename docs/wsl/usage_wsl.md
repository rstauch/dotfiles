### Apply Home-Manager Updates
- edit configuration: `dot` or `hme`
- run `hmu` oder `home-manager switch`
- apply with restart of shell, in case of *tmux*: `CTRL+D` bzw. `tkill`

### Switch home-profile
```shell
# ggf. scripts/uninstall.sh ausführen
# ggf. daten in $HOME/.config etc. löschen
sh scripts/install.sh
# enter different template name than before and open a new shell after successful installation
```

## Switch Java version (direnv)
```shell
cd $PROJECT_DIR
cp $DOTIFLES_DIR/direnv/java/11/*
direnv allow
# test with:
# echo $JAVA_HOME
# java -version
# mvn --version
# gradle -v

# disable with: direnv deny

# evtl. .gitignore.local anlegen und zu .gitignore hinzufügen, dann .envrc und shell.nix auf .gitignore.local hinzufügen
``` 

### Install System Updates
- **Note:** durch WSL install script vollumfänglich abgedeckt `-UPDATE_OS true` (default)
```shell
sudo apt-get update
sudo apt-get -y upgrade
```

### Backup & restore WSL2
```shell
# wsl --export DISTRO-NAME PATH\FILE-NAME.tar
wsl --export wsl-ubuntu-2004-test F:\backup\wsl-ubuntu-2004-test_backup.tar
# change dir sonst funktioniert das compress in place nicht
cd F:\backup
# compress in place
wsl.exe gzip -9 wsl-ubuntu-2004-test_backup.tar

# Restore
# wsl --import DISTRO-NAME INSTALL-LOCATION PATH\FILE-NAME.tar
wsl --import wsl-ubuntu-2004-test D:\code\wsl\wsl-ubuntu-2004-test F:\backup\wsl-ubuntu-2004-test_backup.tar
```
