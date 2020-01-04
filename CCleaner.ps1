
# Silent Install CCleaner
# http://www.piriform.com/ccleaner/download


# Path for the workdir
$workdir = "c:\temp\"

$sixtyFourBit = Test-Path -Path "C:\Program Files (x86)"

$cCleanerInstalled = Test-Path -Path "C:\Program Files\CCleaner"

If ($cCleanerInstalled){
    Write-Host "Installed - running the cleaner!"
    Start-Process -FilePath "C:\Program Files\CCleaner\CCleaner64.exe" -ArgumentList "/AUTO"
} ELSE {
    Write-Host "Doing the installation first"



    # Check if work directory exists if not create it

    If (Test-Path -Path $workdir -PathType Container){
        Write-Host "$workdir already exists" -ForegroundColor Red
    } ELSE {
        New-Item -Path $workdir  -ItemType directory
    }

    # Download the installer

    $source = "https://download.ccleaner.com/ccsetup563.exe"
    $destination = "$workdir\ccsetup.exe"

    # Check if Invoke-Webrequest exists otherwise execute WebClient

    if (Get-Command 'Invoke-Webrequest'){
        Invoke-WebRequest $source -OutFile $destination
    } else {
        $WebClient = New-Object System.Net.WebClient
        $webclient.DownloadFile($source, $destination)
    }

    # Start the installation
    Start-Process -FilePath "$workdir\ccsetup.exe" -ArgumentList "/S"


    # Download custom ccleaner.ini file
    $source = "https://gist.githubusercontent.com/mckinnon81/45903adb39893a2d63b66499fc21cbf1/raw/0d0f14329e85ec428990cd1329b0e9238477013f/ccleaner.ini"
    $destination = "C:\Program Files\CCleaner\ccleaner.ini"

    if (Get-Command 'Invoke-Webrequest'){
        Invoke-WebRequest $source -OutFile $destination
    } else {
        $WebClient = New-Object System.Net.WebClient
        $webclient.DownloadFile($source, $destination)
    }

    Start-Sleep -s 35


    # Start the Clean
    Start-Process -FilePath "C:\Program Files\CCleaner\CCleaner64.exe" -ArgumentList "/AUTO"
}
