# The script is removing the prompt "Press any key to boot from CD/DVD" message, allowing fully unattended OSD
# Example usage: .\Create-Unattended-ISO.ps1 -SourceISOPath "C:\temp\OSD.ISO" -UnattendedISOPath "C:\temp\Unattended.ISO"
##############################
Param (
[Parameter(Mandatory=$true)]
[ValidateScript({Test-Path $_ -PathType Leaf})]
[String]
$SourceISOPath, # Path to the source ISO file; can be relative
[Parameter(Mandatory=$false)]
[String]
$UnattendedISOPath = '.\Unattended.ISO' # Path to the destination ISO file; can be relative

)

# First we make sure that ADK 10 is installed on the local computer and we get its location
$ADKProduct = $null
$ADKProduct = Get-WmiObject -Class Win32_Product | Where {$_.Name -eq "Windows Deployment Tools"}
if ($ADKProduct -ne $null) {
# Now getting the installation folder; we should have a registry key
if (!(Test-Path -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows Kits\Installed Roots")) {
Write-Host -ForegroundColor Yellow "The ADK 10 application has been detected on the current computer, but the installation folder not. Aborting..."
exit
}
else {
# actual installation folder detection
$Props = Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows Kits\Installed Roots"
$ADKPath = $Props.KitsRoot10
Write-Host -ForegroundColor Green "The ADK 10 application has been detected on the current computer."
}
}
else {
Write-Host -ForegroundColor Yellow "The ADK 10 application is not detected as installed on the current computer. Aborting..."
exit
}

# Then we create the parent folder of the output file, if it does not exist
if (!(Test-Path -Path (Split-Path -Path $UnattendedISOPath -Parent))) {
$NewLocation = New-Item -Path (Split-Path -Path $UnattendedISOPath -Parent) -ItemType Directory -Force
Write-Host -ForegroundColor Green "The parent folder of the output ISO file, $($NewLocation.FullName) has been created."
}

# Then we start processing the source ISO file
$SourceISOFullPath = (Get-Item -Path $SourceISOPath).FullName
try {
Mount-DiskImage -ImagePath $SourceISOFullPath
}
catch {
Write-Host -ForegroundColor Yellow 'An error occured while mounting the source ISO file. It may be corrupt. Aborting...'
exit
}
$iSOImage = Get-DiskImage -ImagePath $SourceISOFullPath | Get-Volume
$iSODrive = "$([string]$iSOImage.DriveLetter):"

# Test if we have enough memory on the current Windows drive to perform the operation (twice the size of the IS0)
$ISOItem = Get-Item -Path $SourceISOFullPath
$SystemDrive = Get-WmiObject Win32_LogicalDisk -filter "deviceid=""$env:SystemDrive"""

if (($ISOItem.Length * 2) -le $SystemDrive.FreeSpace) {
Write-Host -ForegroundColor Green "The current system drive appears to have enough free space for the ISO conversion process."
}
else {
Write-Host -ForegroundColor Yellow "The current system drive does not appear to have enough free space for the ISO conversion process. Aborting..."
exit
}

# Process the ISO content using a temporary folder on the local system drive
if (!(Test-Path -Path "$env:TEMP\sourceisotemp" -PathType Container)) {
New-Item -Path "$env:TEMP\sourceisotemp" -ItemType Directory -Force | Out-Null
}
else {
Remove-Item -Path "$env:TEMP\sourceisotemp" -Force -Confirm:$false
New-Item -Path "$env:TEMP\sourceisotemp" -ItemType Directory -Force | Out-Null
}

Write-Host -ForegroundColor Green "Extracting the content of the ISO file."
Get-ChildItem -Path $iSODrive | Copy-Item -Destination "$env:TEMP\sourceisotemp" -Recurse -Container -Force
Write-Host -ForegroundColor Green "The content of the ISO file has been extracted."

# Processing the extracted content
if (Test-Path -Path "$env:TEMP\sourceisotemp\boot\bootfix.bin" -PathType Leaf) {
Remove-Item -Path "$env:TEMP\sourceisotemp\boot\bootfix.bin" -Force -Confirm:$false
}
$oscdimg = $ADKPath + "Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$etfsboot = $ADKPath + "Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\etfsboot.com"
$efisys_noprompt = $ADKPath + "Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\efisys_noprompt.bin"
$parameters = "-bootdata:2#p0,e,b""$etfsboot""#pEF,e,b""$efisys_noprompt"" -u1 -udfver102 ""$env:TEMP\sourceisotemp"" ""$UnattendedISOPath"""

$ProcessingResult = Start-Process -FilePath $oscdimg -ArgumentList $parameters -Wait -NoNewWindow -PassThru

if ($ProcessingResult.ExitCode -ne 0) {
Write-Host -ForegroundColor Yellow "There was an error while creating the iso file."
}
else {
Write-Host -ForegroundColor Green "The content of the ISO has been repackaged in the new ISO file."
}

# Cleaning up
Remove-Item -Path "$env:TEMP\sourceisotemp" -Force -Recurse -Confirm:$false
Write-Host -ForegroundColor Green "The temp folder has been removed."

# Dismount the ISO file as we no longer require it
Dismount-DiskImage -ImagePath $SourceISOFullPath
Write-Host -ForegroundColor Green "The source ISO file has been unmounted."
