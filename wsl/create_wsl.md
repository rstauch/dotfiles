# WSL2 Create Distro
Creates a distro from a tarball and adds a user to it


# Download Canonical Image
```powershell
# https://cloudbytes.dev/snippets/how-to-install-multiple-instances-of-ubuntu-in-wsl2
Remove-Item alias:curl

# change directory
cd F:\downloads

# download the tarball
curl (("https://cloud-images.ubuntu.com",
"releases/focal/release",
"ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz") -join "/") `
--output ubuntu-20.04-wsl-rootfs-tar.gz
```

Clone the repository locally:  
```
# disable execution policy temporarily
PowerShell -ExecutionPolicy Bypass

.\CreateLinuxDistro.ps1 -INPUT_FILENAME F:\downloads\ubuntu-20.04-wsl-rootfs-tar.gz -OUTPUT_DIRNAME "D:\code\wsl" -OUTPUT_DISTRONAME wsl-ubuntu-2004-test-basic -CREATE_USER_USERNAME rstauch
```
## Next steps
- create shortcut `C:\Windows\System32\wsl.exe --distribution wsl-ubuntu-2004-test-2 -u rstauch --cd "~"`
- setup docker (via docker desktop) and verify working w/ `docker ps -a` and `docker run hello-world`

# Delete WSL2 distribution

As stated in the [official documentation](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)
you can delete a WSL2 distribution using the following command:

```wsl --unregister <DistributionName>```
