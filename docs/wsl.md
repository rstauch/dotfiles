# WSL2 Setup
## Create WSL2 Instance
- **Note**: evtl. mit WSL2-Create-Distro kombinieren und weitesgehend voll-automatisieren 

```shell
wsl.exe --update

# clone script
git clone git@github.com:rstauch/WSL2-Create-Distro.git

# execute steps, see: https://github.com/rstauch/WSL2-Create-Distro
```

- Initial Windows shortcut: `C:\Windows\System32\wsl.exe --distribution ${distribution_name} -u ${username} --cd "~"`, ie: `C:\Windows\System32\wsl.exe --distribution Ubuntu-20.04 -u rstauch --cd "~"`

### Setup VcXsrv on Windows Host
- Note: evtl. https://community.chocolatey.org/packages/vcxsrv#files nutzen (inkl. Firewall Rules) 

Download and install on Windows https://sourceforge.net/projects/vcxsrv/files/latest/download

Create shortcut: `"C:\Program Files\VcXsrv\xlaunch.exe" -run "C:\code\config.xlaunch"`

**config.xlaunch**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<XLaunch WindowMode="MultiWindow" ClientMode="NoClient" LocalClient="False" Display="-1" LocalProgram="xcalc" RemoteProgram="xterm" RemotePassword="" PrivateKey="" RemoteHost="" RemoteUser="" XDMCPHost="" XDMCPBroadcast="False" XDMCPIndirect="False" Clipboard="True" ClipboardPrimary="False" ExtraParams="" Wgl="False" DisableAC="True" XDMCPTerminate="False"/>
```
**Note**: Ggf. Windows Firewall Freigaben (**Inbound Rules**) für *VcXsrv* anlegen.


### Enable systemd (already done via WSL2-Create-Distro)
- see https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/
```shell
sudo nano /etc/wsl.conf

# add the following lines
[boot]
systemd=true
```
```shell
# restart wsl
wsl.exe --shutdown

# check with
systemctl list-unit-files --type=service
```

## Install nix home-manager
```shell
mkdir -p ~/projects && cd ~/projects
git clone https://github.com/rstauch/dotfiles.git
cd dotfiles/scripts
./install.sh
# open new shell to apply changes
```

## Apply home-manager configuration
```shell
cd ~/projects/dotfiles
cd scripts

# will run home-wsl-x11.nix
./apply.sh

# enter ssh private key from 1password and confirm with '#'

# exit shell and open new shell from shortcut:
# Windows shortcut: C:\Windows\System32\wsl.exe --distribution ${distribution_name} -u ${username} --cd "~" -e bash -lc zsh
# ie: C:\Windows\System32\wsl.exe --distribution wsl-ubuntu-2004-test -u rstauch --cd "~" -e bash -lc zsh
```

## Install IntelliJ (ultimate) manually
```shell
cd ~/projects/dotfiles
cd scripts/post
# update intellij.sh with latest version if available
./intellij.sh

# login into intellij ultimate with account
# enable settings sync: pull settings from account
# set setting: Enable stating area
# evtl. setting: store passwords in keepass aktivieren
# login into copilot via Tools -> Copilot -> Login to Github

# bei seltsamen Problemen (ui-glitches, copy/paste funktioniert nicht, etc.) kann es helfen, VcXsrv neuzustarten

# start IntelliJ from anywhere with command: idea (zsh alias)
```

## Post-Install Steps

### Docker
- enable Docker Integration and verify with `docker ps -a` and `docker run hello-world`
  - ggf. einfach Docker Setting togglen und un-togglen, danach Shell neu starten

### OneDrive
- login to onedrive
```shell
onedrive 

# URL im Browser aufrufen
# Code aus URL kopieren
```
- sync onedrive with command: `os`
- create project dir in home directory to be synced, i.e: `mkdir -p ~/OneDrive/TestProject`
- create keepass vault in project dir if not already downloaded from sync
  - store vault password in (host) *1Password*
  - store username credentials in Keepass vault
  - store root credentials in Keepass vault
- sync onedrive with command: `os` or start monitoring with `osm`


### Firefox
- log into Firefox and enable settings sync
  - save Firefox credentials to Keepass vault
- enable alle extensions in **Private Windows** if required
- connect Keepass Browser Plugin to KeepassXC  

### Other
- create project specific https://notion.so account (use project email address) and add credentials to keepass vault

### Apply Updates
- edit configuration: `dot` or `hme`
- run `hmu` oder `home-manager switch`

### Transform https dotfiles repo to ssh
- required as no ssh key is setup at time of initial cloning
```shell
# verify ~/.ssh/id_rsa is set up
git remote remove origin
git remote add origin git@github.com:rstauch/dotfiles.git
git fetch
git branch --set-upstream-to=origin/master master
```

### Install Updates
```shell
sudo apt-get update
sudo apt-get upgrade
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


---

TODO: offene Punkte: vereinheitlichung WSL Script + nix; Darwin; Cheatsheet

```shell
# create keepass vault
printf "DB_PWD\nDB_PWD" | keepassxc-cli db-create -p ~/OneDrive/wsl-ubuntu-2004-test/database.kdbx

# add keepass entry
printf "DB_PWD\nENTRY_PWD" | keepassxc-cli add ~/OneDrive/wsl-ubuntu-2004-test/database.kdbx --username "user_name" -p "entry_name"
```