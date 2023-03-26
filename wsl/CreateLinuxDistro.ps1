<#
.SYNOPSIS
    Creates a WSL2 distro and optionally adds a user with group
.DESCRIPTION
    As a general pourpose, when working for different projects or companies,
    one might need to create a self-contained WSL environment, just as one creates a
    Virtual Machine.
    This script will do just that. It creates a WSL distribution from a tarball file,
    and optionally creates a user and adds it to a group (sudo by default).
.EXAMPLE
    Create-Linux-Distro.ps1 -INPUT_FILENAME F:\downloads\ubuntu-20.04-wsl-rootfs-tar.gz -OUTPUT_DIRNAME "D:\code\wsl" -OUTPUT_DISTRONAME ubuntu2004-test-1 -CREATE_USER_USERNAME rstauch -ADD_USER_TO_GROUP_NAME sudo
#>

[CmdletBinding(DefaultParameterSetName = 'Parameter Set 1',
    SupportsShouldProcess = $true,
    PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
[Alias()]
[OutputType([String])]
Param (
    # Input distribution tarball
    [Parameter(
        Mandatory = $true,
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern(".tar.gz$")]
    [ValidateScript( {
            if ( -Not ($_ | Test-Path) ) {
                throw "File or folder does not exist"
            }
            return $true
        })]
    [System.IO.FileInfo]
    [Alias("i")]
    $INPUT_FILENAME,

    # Where the distro will be saved
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]
    $OUTPUT_DIRNAME = "$env:LOCALAPPDATA/Packages/WSLDistributions",

    # The name of the distribution
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^[^<>:""/\\|?*]+$")]
    [string]
    $OUTPUT_DISTRONAME,

    # Username of the user to create
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false,
        ParameterSetName='USER'
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("[a-zA-Z0-9]+")]
    $CREATE_USER_USERNAME,

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

    # Which group should the user be added to (default=sudo)
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $true,
        ParameterSetName='USER'
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    # [string[]]$ADD_USER_TO_GROUP_NAME = @("sudo", "docker"),
    [string[]]$ADD_USER_TO_GROUP_NAME = @("sudo", "systemd-journal"),

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
    Set-StrictMode -Version 2
    $ErrorActionPreference = 'Stop'

    function Create-WSLShortcut {
        [CmdletBinding()]
        param (
            [bool]$zsh = $false,
            [bool]$tmux = $false
        )

        # Set the path for the shortcut
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutName = "WSL-$OUTPUT_DISTRONAME"
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
            $shortcut.Arguments = "--distribution $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME --cd ""~"" -e bash -lc ""zsh -c 'export ZSH_TMUX_AUTOSTART=true && exec zsh'"""
        }
        elseif ($zsh) {
            $shortcut.Arguments = "--distribution $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME --cd ""~"" -e bash -lc zsh"
        }
        else {
            $shortcut.Arguments = "--distribution $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME --cd ""~"""
        }

        $shortcut.Save()
    }


    function Install-Dotfiles {
        Write-Output "Install dotfiles"

        $command = "mkdir -p ~/projects; cd ~/projects; git clone https://github.com/rstauch/dotfiles.git; cd dotfiles/scripts; ./install.sh"

        # Build the command to run in WSL
        $wslCommand = "wsl.exe --distribution $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME bash -c `"$command`""

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
        $wslCommand = "wsl.exe --distribution $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME bash -c `"$command`""
        Invoke-Expression $wslCommand

        Write-Output "Finished installing dotfiles"
    }

    function Install-IntelliJ {
        Write-Output "Install IntellJ Ultimate"

        $command = "cd ~/projects/dotfiles/scripts/post; ./intellij.sh"

        # Build the command to run in WSL
        $wslCommand = "wsl.exe --distribution $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME bash -c `"$command`""

        # Run the command in WSL
        Invoke-Expression $wslCommand

        Write-Output "Finished installing intelliJ Ultimate."
    }

    function Restart-Wsl {
        Write-Output "restarting $OUTPUT_DISTRONAME"
        wsl --terminate $OUTPUT_DISTRONAME
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "exit"
    }

    function Configure-WSLDistribution {
        # pot. perform update to enable systmd support
        wsl --update

        # use wsl v2
        wsl --set-default-version 2

        $output_path = Join-Path $OUTPUT_DIRNAME $OUTPUT_DISTRONAME
        Write-Output "Importing distro $OUTPUT_DISTRONAME using $INPUT_FILENAME to $output_path"
        wsl --import $OUTPUT_DISTRONAME $output_path $INPUT_FILENAME

        Write-Output "Creating user $CREATE_USER_USERNAME"
        wsl -d $OUTPUT_DISTRONAME /usr/sbin/useradd -m $CREATE_USER_USERNAME

        Write-Output "Setting password for user $CREATE_USER_USERNAME"
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "echo -e '$CREATE_USER_PASSWORD\n$CREATE_USER_PASSWORD' | /usr/bin/passwd $CREATE_USER_USERNAME"

        Write-Output "Setting shell for user $CREATE_USER_USERNAME"
        wsl -d $OUTPUT_DISTRONAME /usr/sbin/usermod --shell "/bin/bash" $CREATE_USER_USERNAME

        foreach ($group in $ADD_USER_TO_GROUP_NAME) {
            Write-Output "Creating group $group"
            wsl -d $OUTPUT_DISTRONAME /usr/sbin/groupadd -f $group

            Write-Output "Adding user $CREATE_USER_USERNAME to group $group"
            wsl -d $OUTPUT_DISTRONAME /usr/sbin/adduser $CREATE_USER_USERNAME $group
        }

        # NOTE: we have to set it BEFORE setting the default user, otherwise it will be
        # launched with the user shell, and it will ask us for the password.
        Write-Output "Setting default root password to the selected one"
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "echo -e '$ROOT_PASSWORD\n$ROOT_PASSWORD' | /usr/bin/passwd"

        if ($UPDATE_OS) {
            Write-Output "Update OS"
            wsl -d $OUTPUT_DISTRONAME -u root -e apt-get update -qq
            wsl -d $OUTPUT_DISTRONAME -u root -e apt-get upgrade --with-new-pkgs -yqq
        }

        Write-Output "Setting default user as $CREATE_USER_USERNAME"
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "echo -e '[user]\ndefault=$CREATE_USER_USERNAME' > /etc/wsl.conf"

        # enable systemd
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "echo -e '[boot]\nsystemd=true' > /etc/wsl.conf"
    }

    function Create-WslKeepassDatabase {
        # create keepassxc database with wsl specific entries
        $db_location = "~/keepass_wsl.kdbx"
        wsl -d $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME /bin/bash -c "printf '$WSL_KEEPASS_DB_PASSWORD\n$WSL_KEEPASS_DB_PASSWORD' | ~/.nix-profile/bin/keepassxc-cli db-create -p $db_location"

        wsl -d $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME /bin/bash -c "printf '$WSL_KEEPASS_DB_PASSWORD\n$ROOT_PASSWORD' | ~/.nix-profile/bin/keepassxc-cli add $db_location --username 'root' -p 'wsl-root'"
        wsl -d $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME /bin/bash -c "printf '$WSL_KEEPASS_DB_PASSWORD\n$CREATE_USER_PASSWORD' | ~/.nix-profile/bin/keepassxc-cli add $db_location --username '$CREATE_USER_USERNAME' -p 'wsl-user'"
    }

}

# TODO: evtl. download von wsl base image sofern noch nicht in Download folder vorhanden
process {
    Set-StrictMode -Version 2
    $ErrorActionPreference = 'Stop'

    if ($pscmdlet.ShouldProcess("Target", "Operation")) {
        Configure-WSLDistribution
        Create-WSLShortcut

        # restart distro to actually enable systemd
        Restart-Wsl

        if ($INSTALL_DOTFILES) {
            # TODO: test with wsl-terminal profil
            Install-Dotfiles

            if ($LOGIN_ONEDRIVE) {
                Write-Output "Login to onedrive and start synchronization"
                wsl -d $OUTPUT_DISTRONAME -u $CREATE_USER_USERNAME /bin/bash -c "mkdir -p ~/OneDrive/projects/$OUTPUT_DISTRONAME && ~/.nix-profile/bin/onedrive --synchronize --single-directory projects --verbose"
            }

            Create-WslKeepassDatabase

            Install-IntelliJ

            # restart to finish up and start onedrive monitoring
            Restart-Wsl

            Create-WSLShortcut -zsh $true -tmux $false
            Create-WSLShortcut -zsh $true -tmux $true

            # TODO: setup VcXsrv on Host ? inkl. FW ...
        }

        Write-Output "Successfully created $OUTPUT_DISTRONAME!"

        # TODO: write + open next-steps.md
    }

}

end {
}
