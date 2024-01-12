# EntraForcePasswordChange

## Introduction

This is a cross-platform Powershell script for forcing logout and password
reset on next login for Microsoft Entra ID users. Guest users are excluded by
design. This script supports no-operation mode where it only shows what would
be done.  It is also possible to operate on a subset of users by providing a
wildcard match for UserPrincipalName.

## How does it work?

Under the hood the script obtains OAuth2 tokens with suitable permissions using
Connect-MgGraph and then loops through all the users in Microsoft Entra ID,
then runs its operations on those that match the wildcard.

## Requirements

This script depends on the Microsoft.Graph module which is available via
Powershell Gallery. If the module is not installed the script will try to
install it.

This script has been tested on the following platforms:

* Fedora 38 with Powershell Core 7.4.0

## Usage

Command-line parameters:

    ./EntraForcePasswordChange.ps1 [-TenantId] <String> [-UserPrincipalName] <String> [-Noop]

Test resetting passwords for all (non-guest) users:

    ./EntraForcePasswordChange -TenantId <tenant-id> -Noop -UserPrincipalName "*"

Test resetting password for a specific user:

    ./EntraForcePasswordChange -TenantId <tenant-id> -Noop -UserPrincipalName "john.doe@acme.org"

Test resetting password for all users in a specific domain:

    ./EntraForcePasswordChange -TenantId <tenant-id> -Noop -UserPrincipalName "*@acme.org"

Remove the -Noop switch to actually reset the passwords and force logout.

## Getting help

The script has built-in help:

    Get-Help ./EntraForcePasswordChange.ps1
    Get-Help ./EntraForcePasswordChange.ps1 -examples

## License

See [LICENSE](LICENSE).
