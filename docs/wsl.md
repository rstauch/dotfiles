# WSL2 Setup
## Create WSL2 Instance
```shell
wsl.exe --update

# clone script
git clone git@github.com:rstauch/WSL2-Create-Distro.git

# execute steps, see: https://github.com/rstauch/WSL2-Create-Distro
```

- Initial Windows shortcut: `C:\Windows\System32\wsl.exe --distribution ${distribution_name} -u ${username} --cd "~"`, ie: `C:\Windows\System32\wsl.exe --distribution Ubuntu-20.04 -u rstauch --cd "~"`

### Setup VcXsrv on Windows Host
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
git clone git@github.com:rstauch/dotfiles.git
cd dotfiles/scripts
./install.sh
# open new shell to apply changes
```

## Apply home-manager configuration
```shell
cd ~/projects/dotfiles
cd scripts
./apply.sh

# enter ssh private key from 1password and confirm with '#'

# exit shell and open new shell from shortcut:
# Windows shortcut: C:\Windows\System32\wsl.exe --distribution ${distribution_name} -u ${username} --cd "~" -e bash -lc zsh
# ie: C:\Windows\System32\wsl.exe --distribution wsl-ubuntu-2004-test -u rstauch --cd "~" -e bash -lc zsh
```

## Post-Install Steps
- enable Docker Integration and verify with `docker ps -a` and `docker run hello-world`
- create keepass vault in onedrive default dir (~/OneDrive) (**möglicherweise automatisierbar**)
- manage firefox 
  - create firefox account and store credentials in keepass 
  - install plugins (**möglicherweise automatisierbar**)
  - connect keepass and disable firefox password manager (**möglicherweise automatisierbar**)
  - make default browser (**möglicherweise automatisierbar**)
- login to onedrive
- create project specific https://notion.so account ($project@fluxdev.de) and add credentials to keepass
- (install intelliJ Ultimate) (**möglicherweise automatisierbar**)
- login to IntelliJ and sync settings
- create backup of WSL instance
