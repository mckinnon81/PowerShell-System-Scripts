<#
		.SYNOPSIS
			A Script to Setup a New User for PoolSystems Network

		.DESCRIPTION
			A Script to Setup a New User for PoolSystems Network

		.PARAMETER FirstName
			The Users First Name

		.PARAMETER LastName
			The Users Last Name

		.PARAMETER Template
			The User who you are copying to make the New User.

    .PARAMETER JobTitle
  		The Users Job Title

    .PARAMETER Department
    	The Users Job Department Site

		.EXAMPLE
			PS C:\> NewUser -FirstName "Fred" -LastName "Flintstong" -Template "BarneyR" -JobTitle "Bowler"

		.NOTES
			Additional information about the function.
	#>

Param (
		[Parameter(Mandatory = $true)]
		[string]
		$LastName,

		[Parameter(Mandatory = $true)]
		[string]
		$FirstName,

		[Parameter(Mandatory = $true)]
		[string]
		$Template,

		[string]
		$JobTitle,

		[Parameter(Mandatory = $true)]
		[ValidateSet("Adelaide","Brisbane","Gold Coast","Melbourne","SMR","Sydney")]
		[string]
		$Department,

		[string]
		$Direct,

		[string]
		$MobilePhone


	)

$LastInitial = $LastName.Substring(0,1)
$UserName = $FirstName + $LastInitial

If ($Department -eq "Adelaide") {
  $OU = "OU=Adelaide,OU=Users,OU=Poolsystems,DC=poolsystems,DC=local"
}
elseif ($Department -eq "Brisbane") {
	$OU = "OU=Brisbane,OU=Users,OU=Poolsystems,DC=poolsystems,DC=local"
}
elseif ($Department -eq "Gold Coast") {
	$OU = "OU=Gold Coast,OU=Users,OU=Poolsystems,DC=poolsystems,DC=local"
}
elseif ($Department -eq "Melbourne") {
	$OU = "OU=Gold Coast,OU=Users,OU=Poolsystems,DC=poolsystems,DC=local"
}
elseif ($Department -eq "SMR") {
	$OU = "OU=Seventeen Mile Rocks,OU=Users,OU=Poolsystems,DC=poolsystems,DC=local"
}
elseif ($Department -eq "Sydney") {
	$OU = "OU=Sydney,OU=Users,OU=Poolsystems,DC=poolsystems,DC=local"
}




Write-Host "Creating New User:" -Foregroundcolor Yellow
Write-Host "First Name:" $FirstName -Foregroundcolor Green
Write-Host "LastName: " $LastName -Foregroundcolor Yellow
Write-Host "Username:" $UserName -Foregroundcolor Yellow

$NewUser = New-ADUser -Surname $LastName -GivenName $FirstName -DisplayName "$FirstName $LastName" -Title $JobTitle -SamAccountName $UserName -Name "$FirstName $LastName" -Department $Department -Path $OU -AccountPassword (ConvertTo-SecureString "Welcome1" -AsPlainText -force) -UserPrincipalName "$UserName@poolsystems.local" -Enabled $true

# Copy from old User
Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf (Get-ADPrincipalGroupMembership $Template | Where {$_.Name -ne "Domain Users"})

If ($Direct -eq "") {

}
else
{
	Set-User $UserName -Phone "$Direct"
}

If ($Mobile -eq "") {

}
else
{
	Set-User $UserName -MobilePhone "$MobilePhone"
}



Enable-Mailbox $UserName
