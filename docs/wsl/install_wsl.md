# WSL2 Setup

### Setup VcXsrv on Windows Host
**Note:** evtl. https://community.chocolatey.org/packages/vcxsrv#files nutzen (inkl. Firewall Rules)

Download and install on Windows https://sourceforge.net/projects/vcxsrv/files/latest/download

Create shortcut: `"C:\Program Files\VcXsrv\xlaunch.exe" -run "C:\code\config.xlaunch"`

**config.xlaunch**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<XLaunch WindowMode="MultiWindow" ClientMode="NoClient" LocalClient="False" Display="-1" LocalProgram="xcalc" RemoteProgram="xterm" RemotePassword="" PrivateKey="" RemoteHost="" RemoteUser="" XDMCPHost="" XDMCPBroadcast="False" XDMCPIndirect="False" Clipboard="True" ClipboardPrimary="False" ExtraParams="" Wgl="False" DisableAC="True" XDMCPTerminate="False"/>
```
**Note**: Ggf. Windows Firewall Freigaben (**Inbound Rules**) für *VcXsrv* anlegen.

### (Optional) Auto-Create WSL2 Instance
see [create_wsl.md](../../wsl/create_wsl_dist.md) for information on how to run the WSL setup script.

## Manually install nix home-manager
- **Note:** durch WSL install script vollumfänglich abgedeckt
```shell
mkdir -p $HOME/projects && cd $HOME/projects
git clone https://github.com/rstauch/dotfiles.git
cd dotfiles/scripts

# enter private key and template file name
./install.sh
# open new shell to apply changes

# create Windows shortcuts
# bash
# C:\Windows\System32\wsl.exe --distribution ${distribution_name} -u ${USR} --cd "~"
# zsh
# C:\Windows\System32\wsl.exe --distribution ${distribution_name} -u ${USR} --cd "~" -e bash -lc zsh
# tmux
# C:\Windows\System32\wsl.exe --distribution ${distribution_name} -u ${USR} --cd "~" -e bash -lc "zsh -c 'export ZSH_TMUX_AUTOSTART=true && exec zsh'"
```

## Required Post-Install Steps

### Docker
- enable Docker Integration and verify with `docker ps -a` and `docker run hello-world`
  - ggf. einfach Docker Setting togglen und un-togglen, danach Shell neu starten
  - ansonsten docker neustarten und mit neuer Shell erneut probieren

### Install IntelliJ (ultimate)
```shell
# Note: script execution already integrated in WSL script flow
cd $HOME/projects/dotfiles
cd scripts/post
# update intellij.sh with latest version if available
./intellij.sh
```
#### Manual Steps
*Note*: bei seltsamen Problemen (ui-glitches, copy/paste funktioniert nicht, etc.) kann es helfen, *VcXsrv* neuzustarten
- start *IntelliJ* from anywhere with command: `idea`
- login into IntelliJ with JetBrains account
- enable settings sync: pull settings from account
- set setting: *Enable staging area*
- set directory settings: 
  - open files with single click
  - always select opened file
- evtl. setting: *store passwords in keepass* aktivieren
- login into copilot via *Tools -> Copilot -> Login to Github*

### Setup Firefox
- start with `ff` (incl. **Keepass**) or with `firefox`
- log into Firefox and enable settings sync
  - save Firefox credentials to Keepass vault
- pot. enable all pre-installed extensions (`about:addons`)
- check Connection Keepass Browser Plugin to KeepassXC

### Notion
- create project specific https://notion.so account (use project email address) 
- add credentials to keepass vault


### Login to OneDrive
- **Note:** durch WSL install script vollumfänglich abgedeckt `-LOGIN_ONEDRIVE  true` (default)

```shell
# start login
onedrive 

# URL im Browser aufrufen
# Code aus URL kopieren
```
- sync onedrive `projects` folder with command: `os`
- create project specific folder in home directory to be synced, i.e: `mkdir -p $HOME/OneDrive/projects/TetstProject`
- load monitor service: `systemctl --user restart onedrive.service`

### Run setup script
```shell
# sets up repos, direnv etc
# zsh alias for $HOME/setup.sh
setup
```

---

TODO: offene Punkte:
Darwin;
? vscode plugin scratchpad
? vscode keybindings wie intellij
ff sync profil evtl. über env steuern (aus wsl script)
