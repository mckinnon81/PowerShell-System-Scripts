
#Create System Restore Point named On-Boarding
#Create Local Admin account  (hidden from user logon screen but enabled, no password expire date)
#Create folder C:\IT Department
#Get User List and save to C:\IT Department
#Set Power Settings to Monitor Off at 10 min. Sleep and HDD off never.


#Version 1.0- Authour Nick Lenius

# 1.creating the restore point
Checkpoint-Computer -Description "On-boarding" -RestorePointType "MODIFY_SETTINGS"
Write-Host "System Restore Point created successfully"

#2.Create Local Admin account  (hidden from user logon screen but enabled, no password expire date)



$Username = "trio"
$Password = "18BealSt"
$group = "Administrators"

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | where {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }

if ($existing -eq $null) {

    Write-Host "Creating new local user $Username."
    & NET USER $Username $Password /add /y /expires:never

    Write-Host "Adding local user $Username to $group."
    & NET LOCALGROUP $group $env:COMPUTERNAME\$Username /add

}
else {
    Write-Host "Setting password for existing local user $Username."
    $existing.SetPassword($Password)
}

Write-Host "Ensuring password for $Username never expires."
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE

# hiding user account from logon screen

$path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
New-Item $path -Force | New-ItemProperty -Name $Username -Value 0 -PropertyType DWord -Force

#####

#3.Create folder C:\options

$nfldr = new-object -ComObject scripting.filesystemobject

$nfldr.CreateFolder("C:\options")

#4.Get User List and save to C:\options

get-localuser  | Select name,Enabled > C:\Options\Userlist.txt

#5.Set Power Settings to Monitor Off at 10 min. Sleep and HDD off never.

 #powercfg /change monitor-timeout-ac 10
 #powercfg /change monitor-timeout-dc 10


 powercfg /change disk-timeout-ac 0
 powercfg /change disk-timeout-dc 0

 powercfg /change standby-timeout-ac 0
 powercfg /change standby-timeout-dc 0

 Write-Host "Power settngs are saved"

# Set TimeZone

 Set-TimeZone -Name "E. Australia Standard Time"

 Write-host "Set timezone to E. Australia Standard Time" -ForegroundColor Yellow
