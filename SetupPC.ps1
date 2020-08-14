
#Create System Restore Point named On-Boarding
#Create Local Admin account  (hidden from user logon screen but enabled, no password expire date)
#Create folder C:\IT Department
#Get User List and save to C:\IT Department
#Set Power Settings to Monitor Off at 10 min. Sleep and HDD off never.

#Version 1.0- Authour Nick Lenius

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Workaround for nested chocolatey folders resulting in path too long error

# Trust PSGallery
Get-PackageProvider -Name NuGet -ForceBootstrap
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Temporary

Disable-UAC

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

#$nfldr = new-object -ComObject scripting.filesystemobject

#$nfldr.CreateFolder("C:\options")

# Get User List and save to C:\options

get-localuser  | Select name,Enabled > C:\Options\Userlist.txt

# Set Power Settings to Monitor Off at 10 min. Sleep and HDD off never.
Write-Host "Power settngs are saved"
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0



 # Set Timezone

Write-host "Set timezone to E. Australia Standard Time"
Set-TimeZone -Name "E. Australia Standard Time"



# Install Software

# Add .Net 3.5
#Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3"


# Install Chocolatey
# Install Chocolatey Software
choco feature enable -n=allowGlobalConfirmation
choco install anydesk.install -y
choco install googlechrome -y
choco install 7zip -y
choco install notepad2-mod -y
choco install notepadplusplus -y
choco install vcredist-all -y
choco install vlc -y
choco install foxitreader -y
choco install dotnetfx -y
choco install dotnetcore -y
choco install libreoffice -y
choco install powershell-core -y


Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
Enable-UAC
