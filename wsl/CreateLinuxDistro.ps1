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
    Create-Linux-Distro.ps1 -INPUT_FILENAME focal-server-cloudimg-amd64-wsl.rootfs.tar.gz -OUTPUT_DIRNAME "%LOCALAPPDATA%/ubuntu2004-1" -OUTPUT_DISTRONAME ubuntu2004-1 -CREATE_USER_USERNAME test1 -ADD_USER_TO_GROUP_NAME sudo
.EXAMPLE
    Create-Linux-Distro.ps1 -INPUT_FILENAME focal-server-cloudimg-amd64-wsl.rootfs.tar.gz -OUTPUT_DIRNAME "" -OUTPUT_DISTRONAME DISTRONAME -CREATE_USER_USERNAME test1  -ADD_USER_TO_GROUP_NAME blabla
.INPUTS
    Help needed here!
.OUTPUTS
    Help needed here!
.NOTES
    Help needed here!
.COMPONENT
    Help needed here!
.ROLE
    Help needed here!
.FUNCTIONALITY
    Help needed here!
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
    $OUTPUT_DISTRONAME,

    # The default shell
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    $DEFAULT_SHELL = "/bin/bash",

    # Whether or not to create a user along with the distribution
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false,
        ParameterSetName='USER'
    )]
    [bool]
    $CREATE_USER = $true,

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

    # Whether or not to automatically add the user to a group
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false,
        ParameterSetName='USER'
    )]
    [bool]
    $ADD_USER_TO_GROUP = $true,

    # Which group should the user be added to (default=sudo)
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $true,
        ParameterSetName='USER'
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
     # specify the parameter as an array of strings
    [string[]]$ADD_USER_TO_GROUP_NAME = @("sudo", "docker"),

    # Which user should be set as the default
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false
    )]
    [ValidateNotNull()]
    $SET_USER_AS_DEFAULT = "root",

    # The default password for the root user
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false
    )]
    $ROOT_PASSWORD = "changeme"
)

begin {
}

process {

    if ($pscmdlet.ShouldProcess("Target", "Operation")) {
        # pot. perform update to enable systmd support
        # wsl --update
        
        # use wsl v2
        wsl --set-default-version 2
        
        Write-Output "Importing distro $OUTPUT_DISTRONAME using $INPUT_FILENAME to $OUTPUT_DIRNAME"
        wsl --import $OUTPUT_DISTRONAME $OUTPUT_DIRNAME $INPUT_FILENAME

        Write-Output "Creating user $CREATE_USER_USERNAME"
        wsl -d $OUTPUT_DISTRONAME /usr/sbin/useradd -m $CREATE_USER_USERNAME

        Write-Output "Setting password for user $CREATE_USER_USERNAME to $CREATE_USER_PASSWORD"
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "echo -e '$CREATE_USER_PASSWORD\n$CREATE_USER_PASSWORD' | /usr/bin/passwd $CREATE_USER_USERNAME"

        Write-Output "Setting shell for user $CREATE_USER_USERNAME to $DEFAULT_SHELL"
        wsl -d $OUTPUT_DISTRONAME /usr/sbin/usermod --shell $DEFAULT_SHELL $CREATE_USER_USERNAME

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

        Write-Output "Setting default user as $SET_USER_AS_DEFAULT"
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "echo -e '[user]\ndefault=$SET_USER_AS_DEFAULT' > /etc/wsl.conf"

        # enable systemd
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "echo -e '[boot]\nsystemd=true' > /etc/wsl.conf"

        # restart distro to enable systemd
        wsl --terminate $OUTPUT_DISTRONAME
        wsl -d $OUTPUT_DISTRONAME /bin/bash -c "exit"

        # TODO: create desktop shortcut (flag)
        # TODO: pot. run dotfiles repo (flag)
        # TODO: create projects dir
        # mkdir -p ~/projects
        # cd ~/projects
        # git clone https://github.com/rstauch/dotfiles.git
        # cd scripts
        # ./apply.sh
        # TODO: create zsh shortcut on desktop
    }

}

end {
}
