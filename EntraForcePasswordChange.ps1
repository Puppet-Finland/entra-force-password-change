<#
.SYNOPSIS
    Force logout and password reset on next login for Microsoft Entra ID users.
.DESCRIPTION
    This script can be used to force logout and password reset on next login
    for Microsoft Entra ID users. Guest users are excluded by design. This
    script supports no-operation mode where it only shows what would be done.
    It is also possible to operate on a subset of users by providing a
    wildcard match for UserPrincipalName.

    Under the hood the script obtains OAuth2 tokens with suitable permissions
    using Connect-MgGraph and then loops through all the users in Microsoft
    Entra ID, then runs its operations on those that match the wildcard.
.PARAMETER TenantId
    The Azure Tenant ID to connect to. This is primarily a safeguard to avoid
    accidentally touching a user directory you did not intend to. Getting the
    value for this is easiest by checking the Overview page from Microsoft
    Entra ID.
.PARAMETER UserPrincipalName
    Operate on users that match this wildcard. This can be a fixed string like "john.doe@acme.org"
    or a wilcard such as "*" (any user) or "*acme.org" (any acme.org user). This gets passed to
    a string comparison done with the -like operator.
.PARAMETER Noop
    Only show what changes would be made.
.EXAMPLE
    Test resetting passwords for all (non-guest) users:

    ForcePasswordChange -TenantId <tenant-id> -Noop -UserPrincipalName "*"
.EXAMPLE
    Reset passwords for all (non-guest) users:

    ForcePasswordChange -TenantId <tenant-id> -UserPrincipalName "*"
.EXAMPLE
    Reset password for a specific user:

    ForcePasswordChange -TenantId <tenant-id> -UserPrincipalName "john.doe@acme.org"
.EXAMPLE
    Reset password for all users in a specific domain:

    ForcePasswordChange -TenantId <tenant-id> -UserPrincipalName "*@acme.org"
#>
param (
  [Parameter(Mandatory=$true)]
  [string]$TenantId,

  [Parameter(Mandatory=$true)]
  [SupportsWildCards()]
  [string]$UserPrincipalName,
  [Switch]$Noop

)

# This module is not installed by default as it comes from the Powershell Gallery as of January 2024
Install-Module Microsoft.Graph

# Connect and get the required oauth2 tokens
Connect-MgGraph -TenantId $TenantId -Scopes Directory.AccessAsUser.All, Directory.ReadWrite.All, User.ReadWrite.All

# Rules to force a password reset on next login
$Passwordprofile = @{}
$Passwordprofile["forceChangePasswordNextSignIn"] = $True
$Passwordprofile["forceChangePasswordNextSignInWithMfa"] = $True

# Loop through all users in Microsoft Entra ID (formerly known as Azure Active
# Directory)
foreach ($User in $(Get-MgUser)) {

    # Do not attempt to do anything to guest (external) users
    if ($User.UserPrincipalName -notmatch "#EXT#" -and $User.UserPrincipalName -like $UserPrincipalName) {
	$CurrentUserId = $User.Id
	$CurrentUserPrincipalName = $User.UserPrincipalName

        if ($Noop) {
	    Write-Host "Would update user ${CurrentUserPrincipalName}"
	    Write-Host "Would run: Revoke-MgUserSignInSession -UserId ${CurrentUserId}"
	    Write-Host "Would run: Update-MgUser -UserId ${CurrentUserid} -PasswordProfile ${Passwordprofile} -Verbose"
	    Write-Host
	} else {
            Revoke-MgUserSignInSession -UserId $CurrentUserId
	    Update-MgUser -UserId $CurrentUserid -PasswordProfile $Passwordprofile -Verbose
	}
    }
}
