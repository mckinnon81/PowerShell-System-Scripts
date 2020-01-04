
#Create System Restore Point named On-Boarding
#Create Local Admin account  (hidden from user logon screen but enabled, no password expire date)
#Create folder C:\IT Department
#Get User List and save to C:\IT Department
#Set Power Settings to Monitor Off at 10 min. Sleep and HDD off never.

#Version 1.0- Authour Nick Lenius

set-executionpolicy Unrestricted -Force

# Creating the restore point
Checkpoint-Computer -Description "On-boarding" -RestorePointType "MODIFY_SETTINGS"
Write-Host "System Restore Point created successfully"

# Create Local Admin account  (hidden from user logon screen but enabled, no password expire date)

$Username = "support"
$Password = "8ug58unny"

$group = "Administrators"

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | where {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }

if ($existing -eq $null) {

    Write-Host "Creating new local user $Username."
    & NET USER $Username $Password /add /y /expires:never

    Write-Host "Adding local user $Username to $group."
    & NET LOCALGROUP $group $Username /add

}
else {
    Write-Host "Setting password for existing local user $Username."
    $existing.SetPassword($Password)
}

Write-Host "Ensuring password for $Username never expires."
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE

# Hiding user account from logon screen

$path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
New-Item $path -Force | New-ItemProperty -Name $Username -Value 0 -PropertyType DWord -Force

#####

# Create folder C:\options

$nfldr = new-object -ComObject scripting.filesystemobject

$nfldr.CreateFolder("C:\options")

# Get User List and save to C:\options

get-localuser  | Select name,Enabled > C:\Options\Userlist.txt

# Set Power Settings to Monitor Off at 10 min. Sleep and HDD off never.

 #powercfg /change monitor-timeout-ac 10
 #powercfg /change monitor-timeout-dc 10


 powercfg /change disk-timeout-ac 0
 powercfg /change disk-timeout-dc 0

 powercfg /change standby-timeout-ac 0
 powercfg /change standby-timeout-dc 0

 Write-Host "Power settngs are saved"

 # Set Timezone

 Set-TimeZone -Name "E. Australia Standard Time"

 Write-host "Set timezone to E. Australia Standard Time"

# Install Software

# Add .Net 3.5
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3"

# Install Chocolatey
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

# Install Chocolatey Software

choco install googlechrome -y
choco install 7zip -y
choco install notepad2 -y
choco install notepadplusplus -y
choco install vcredist-all -y
choco install vlc -y
choco install foxitreader -y
choco install dotnetfx -y
