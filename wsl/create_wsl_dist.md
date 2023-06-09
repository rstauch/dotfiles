# WSL2 Create Distro
Creates a distro from a tarball and adds a user to it.

## Download Image (optional)
```shell
# https://cloudbytes.dev/snippets/how-to-install-multiple-instances-of-ubuntu-in-wsl2

cd $DOWNLOADS
Remove-Item alias:curl

# download the tarball
curl (("https://cloud-images.ubuntu.com",
"releases/focal/release",
"ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz") -join "/") `
--output ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz

```

## Execute Script
```powershell
# clone the repository locally:
# (D:\code\dotfiles)
cd $PROJECTS
git clone git@github.com:rstauch/dotfiles.git # or: git clone https://github.com/rstauch/dotfiles.git

# disable execution policy temporarily
PowerShell -ExecutionPolicy Bypass

# start script, auto-download image
.\WslDist.ps1 -OUTPUT_DIR "D:\code\wsl" -DISTRO "wsl-ubuntu-2004-test" -USR rstauch

# start script (with specific image)
.\WslDist.ps1 -INPUT F:\downloads\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -OUTPUT_DIR "D:\code\wsl" -DISTRO "wsl-ubuntu-2004-test" -USR rstauch

# or, with auto-download:
# .\WslDist.ps1 -OUTPUT_DIR "D:\code\wsl" -DISTRO wsl-ubuntu-2004-test-basic -USR rstauch

# additional paramters
# -UPDATE_OS true/false: run apt-get upgrade (default true)
# -INSTALL_DOTFILES true/false: clone dotfiles repo (default true)
# -LOGIN_ONEDRIVE true/false: synchronize with OneDrive (default true)
# -INSTALL_INTELLIJ true/false: install IntelliJ in a post-installation step (default true)
# -WSL_KEEPASS_DB_PASSWORD [string]: password for pre-populated keepassxc database stored at ~/keepass_wsl.kdbx
```

## Keepass DB
````shell
# keepass db (kepass_wsl.kdbx) can be found at ~
# open with keepassxc or keepassxc-cli
````

# Delete WSL2 distribution
As stated in the [official documentation](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)
you can delete a WSL2 distribution using the following command:

```wsl --unregister <DistributionName>```
