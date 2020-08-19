
# Silent Install CCleaner
# http://www.piriform.com/ccleaner/download

function DownloadINI {

  $source = "https://gist.githubusercontent.com/mckinnon81/45903adb39893a2d63b66499fc21cbf1/raw/0d0f14329e85ec428990cd1329b0e9238477013f/ccleaner.ini"
  $destination = "C:\Program Files\CCleaner\ccleaner.ini"

  if (Get-Command 'Invoke-Webrequest'){
      Invoke-WebRequest $source -OutFile $destination
  } else {
      $WebClient = New-Object System.Net.WebClient
      $webclient.DownloadFile($source, $destination)
  }
}

# Path for the workdir
$workdir = "c:\temp\"
$cCleanerInstalled = Test-Path -Path "C:\Program Files\CCleaner"

DownloadINI
If ($cCleanerInstalled){
    Write-Host "Installed - running the cleaner!"
    Start-Process -FilePath "C:\Program Files\CCleaner\CCleaner64.exe" -ArgumentList "/AUTO"
} ELSE {
    Write-Host "Doing the installation first"
    choco install ccleaner

    # Download custom ccleaner.ini file
    DownloadINI

    # Start the Clean
    Start-Process -FilePath "C:\Program Files\CCleaner\CCleaner64.exe" -ArgumentList "/AUTO"
}
