<#
.SYNOPSIS
    Creates a WSL2 distro and optionally adds a user with group
.DESCRIPTION
    As a general pourpose, when working for different projects or companies,
    one might need to create a self-contained WSL environment, just as one creates a
    Virtual Machine.
    This script will do just that. It creates a WSL distribution from a tarball file,
    and optionally creates a user and adds it to a group (sudo by default).
    Might be required to run: PowerShell -ExecutionPolicy Bypass first
.EXAMPLE
    WslDist.ps1 -INPUT F:\downloads\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -OUTPUT_DIR "D:\code\wsl" -DISTRO ubuntu2004-test -USR rstauch
.EXAMPLE
    WslDist.ps1 -OUTPUT_DIR "D:\code\wsl" -DISTRO ubuntu2004-test -USR rstauch
 #>
#>

[CmdletBinding(DefaultParameterSetName = 'Parameter Set 1',
    SupportsShouldProcess = $true,
    PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
[Alias()]
[OutputType([String])]
Param (
    [Parameter(
        Mandatory = $false,
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        ValueFromRemainingArguments = $false)]
    $INPUT,

    # Where the distro will be saved
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]
    $OUTPUT_DIR = "$env:LOCALAPPDATA/Packages/WSLDistributions",

    # The name of the distribution
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^[^<>:""/\\|?*]+$")]
    [string]
    $DISTRO,

    # USR of the user to create
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false,
        ParameterSetName='USER'
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("[a-zA-Z0-9]+")]
    $USR,

    # The password for the user
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false,
        ParameterSetName='USER'
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    $CREATE_USER_PASSWORD,

    # Which group should the user be added to
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $true,
        ParameterSetName='USER'
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [string[]]$USR_GRP = @("sudo", "systemd-journal", "docker"),

    # The default password for the root user
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    $ROOT_PASSWORD,

    [Parameter()]
    [bool]
    $UPDATE_OS = $true,

    [Parameter()]
    [bool]
    $INSTALL_DOTFILES = $true,

    [Parameter()]
    [bool]
    $LOGIN_ONEDRIVE = $true,

    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    $WSL_KEEPASS_DB_PASSWORD
)

begin {
    function Download-Image {
        # https://cloudbytes.dev/snippets/how-to-install-multiple-instances-of-ubuntu-in-wsl2
        $download_path = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
        $output_file = "ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz"

        $downloadedFile = "$download_path\$output_file"

        if (Test-Path $downloadedFile -PathType Leaf) {
            Write-Host "File $downloadedFile already exists."
        } else {
            Write-Host "Download to $downloadedFile"
            & "${env:SystemRoot}\System32\curl.exe" (("https://cloud-images.ubuntu.com", "releases/focal/release", "$output_file") -join "/") `--output "$downloadedFile"
        }
        return "$downloadedFile"
    }

    function Create-WSLShortcut {
        [CmdletBinding()]
        param (
            [bool]$zsh = $false,
            [bool]$tmux = $false
        )

        # Set the path for the shortcut
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutName = "WSL-$DISTRO"
        if ($tmux) {
            $shortcutName += "-tmux"
        }
        elseif ($zsh) {
            $shortcutName += "-zsh"
        }

        $shortcutPath = "$desktopPath\$shortcutName.lnk"

        # Get the path to wsl.exe
        $wslPath = (Get-Command wsl.exe).Source

        # Create a shortcut object
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $wslPath
        if ($zsh -and $tmux) {
            $shortcut.Arguments = "--distribution $DISTRO -u $USR --cd ""~"" -e bash -lc ""zsh -c 'export ZSH_TMUX_AUTOSTART=true && exec zsh'"""
        }
        elseif ($zsh) {
            $shortcut.Arguments = "--distribution $DISTRO -u $USR --cd ""~"" -e bash -lc zsh"
        }
        else {
            $shortcut.Arguments = "--distribution $DISTRO -u $USR --cd ""~"""
        }

        $shortcut.Save()
    }


    function Install-Dotfiles {
        Write-Host "Install dotfiles"

        $command = "mkdir -p ~/projects; cd ~/projects; git clone https://github.com/rstauch/dotfiles.git; cd dotfiles/scripts; ./install.sh"

        # Build the command to run in WSL
        $wslCommand = "wsl.exe --distribution $DISTRO -u $USR bash -c `"$command`""

        # Run the command in WSL
        Invoke-Expression $wslCommand

        # convert repo to ssh
        $commands = @(
        "cd ~/projects/dotfiles",
        "git remote remove origin",
        "git remote add origin git@github.com:rstauch/dotfiles.git",
        "git fetch",
        "git branch --set-upstream-to=origin/master master"
        )
        $command = $commands -join ';'
        $wslCommand = "wsl.exe --distribution $DISTRO -u $USR bash -c `"$command`""
        Invoke-Expression $wslCommand

        Write-Host "Finished installing dotfiles"
    }

    function Install-IntelliJ {
        Write-Host "Install IntellJ Ultimate"

        $command = "cd ~/projects/dotfiles/scripts/post; ./intellij.sh"

        # Build the command to run in WSL
        $wslCommand = "wsl.exe --distribution $DISTRO -u $USR bash -c `"$command`""

        # Run the command in WSL
        Invoke-Expression $wslCommand

        Write-Host "Finished installing intelliJ Ultimate."
    }

    function Restart-Wsl {
        Write-Host "restarting $DISTRO"
        wsl --terminate $DISTRO
        wsl -d $DISTRO /bin/bash -c "exit"
    }

    function Check-VariableNotNullOrEmpty {
        param(
            [Parameter(Mandatory=$true)]
            [string]$strVariable
        )

        if ($strVariable -eq $null -or $strVariable -eq "") {
            Write-Error "$strVariable is null or empty."
            exit 1
        }
    }


    function Configure-WSLDistribution {
        param (
            [string]$tar_file
        )
        # pot. perform update to enable systemd support
        wsl --update

        # use wsl v2
        wsl --set-default-version 2

        Check-VariableNotNullOrEmpty -strVariable $DISTRO
        Check-VariableNotNullOrEmpty -strVariable $USR
        Check-VariableNotNullOrEmpty -strVariable $ROOT_PASSWORD
        Check-VariableNotNullOrEmpty -strVariable $CREATE_USER_PASSWORD

        $output_path = Join-Path $OUTPUT_DIR $DISTRO

        Write-Host "Importing distro $DISTRO using $tar_file. Set $output_path"
        wsl --import $DISTRO $output_path $tar_file
        if(!$?) { Exit $LASTEXITCODE }

        Write-Host "Creating user $USR"
        wsl -d $DISTRO /usr/sbin/useradd -m $USR
        if(!$?) { Exit $LASTEXITCODE }

        Write-Host "Setting password for user $USR"
        wsl -d $DISTRO /bin/bash -c "echo -e '$CREATE_USER_PASSWORD\n$CREATE_USER_PASSWORD' | /usr/bin/passwd $USR"
        if(!$?) { Exit $LASTEXITCODE }

        Write-Host "Setting shell for user $USR"
        wsl -d $DISTRO /usr/sbin/usermod --shell "/bin/bash" $USR
        if(!$?) { Exit $LASTEXITCODE }

        foreach ($group in $USR_GRP) {
            Write-Host "Creating group $group"
            wsl -d $DISTRO /usr/sbin/groupadd -f $group
            if(!$?) { Exit $LASTEXITCODE }

            Write-Host "Adding user $USR to group $group"
            wsl -d $DISTRO /usr/sbin/adduser $USR $group
            if(!$?) { Exit $LASTEXITCODE }
        }

        # NOTE: we have to set it BEFORE setting the default user, otherwise it will be
        # launched with the user shell, and it will ask us for the password.
        Write-Host "Setting default root password to the selected one"
        wsl -d $DISTRO /bin/bash -c "echo -e '$ROOT_PASSWORD\n$ROOT_PASSWORD' | /usr/bin/passwd"
        if(!$?) { Exit $LASTEXITCODE }

        if ($UPDATE_OS) {
            Write-Host "Update OS"
            wsl -d $DISTRO -u root -e apt-get update -qq
            if(!$?) { Exit $LASTEXITCODE }

            wsl -d $DISTRO -u root -e apt-get upgrade --with-new-pkgs -yqq
            if(!$?) { Exit $LASTEXITCODE }
        }

        Write-Host "Setting default user as $USR"
        wsl -d $DISTRO /bin/bash -c "echo -e '[user]\ndefault=$USR' > /etc/wsl.conf"
        if(!$?) { Exit $LASTEXITCODE }

        # https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/
        wsl -d $DISTRO /bin/bash -c "echo -e '[boot]\nsystemd=true' > /etc/wsl.conf"
        if(!$?) { Exit $LASTEXITCODE }
    }

    function Create-WslKeepassDatabase {
        # create keepassxc database with wsl specific entries
        $db_location = "~/keepass_wsl.kdbx"
        wsl -d $DISTRO -u $USR /bin/bash -c "printf '$WSL_KEEPASS_DB_PASSWORD\n$WSL_KEEPASS_DB_PASSWORD' | ~/.nix-profile/bin/keepassxc-cli db-create -p $db_location"

        wsl -d $DISTRO -u $USR /bin/bash -c "printf '$WSL_KEEPASS_DB_PASSWORD\n$ROOT_PASSWORD' | ~/.nix-profile/bin/keepassxc-cli add $db_location --username 'root' -p 'wsl-root'"
        wsl -d $DISTRO -u $USR /bin/bash -c "printf '$WSL_KEEPASS_DB_PASSWORD\n$CREATE_USER_PASSWORD' | ~/.nix-profile/bin/keepassxc-cli add $db_location --username '$USR' -p 'wsl-user'"
    }

}

process {
    if ($pscmdlet.ShouldProcess("Target", "Operation")) {

        $effective_image = "$INPUT"
        if (-not [string]::IsNullOrEmpty($INPUT)) {
            Write-Host "Continue with $INPUT"
        } else {
            $effective_image = Download-Image
        }

        Configure-WSLDistribution -tar_file $effective_image
        Create-WSLShortcut

        # restart distro to actually enable systemd
        Restart-Wsl

        if ($INSTALL_DOTFILES) {
            # TODO: test with wsl-terminal profil
            Install-Dotfiles

            if ($LOGIN_ONEDRIVE) {
                Write-Host "Login to onedrive and start synchronization"
                wsl -d $DISTRO -u $USR /bin/bash -c "mkdir -p ~/OneDrive/projects/$DISTRO && ~/.nix-profile/bin/onedrive --synchronize --single-directory projects --verbose"
            }

            Create-WslKeepassDatabase

            Install-IntelliJ

            # restart to finish up and start onedrive monitoring
            Restart-Wsl

            Create-WSLShortcut -zsh $true -tmux $false
            Create-WSLShortcut -zsh $true -tmux $true

            # TODO: setup VcXsrv on Host ? inkl. FW ...
        }

        Write-Host "Successfully created $DISTRO!"
    }

}

end {
}
