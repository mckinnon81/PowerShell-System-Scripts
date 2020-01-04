# script created to pull Average CPU, RAM and HDD usage
# the details are for the comptuer that run this script on (For single computer)
$AVGProc = Get-WmiObject  win32_processor |
Measure-Object -property LoadPercentage -Average | Select Average
$OS = gwmi -Class win32_operatingsystem  |
Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}
$vol = Get-WmiObject -Class win32_Volume  -Filter "DriveLetter = 'C:'" |
Select-object @{Name = "C PercentFree"; Expression = {“{0:N2}” -f  (($_.FreeSpace / $_.Capacity)*100) } }

$result =  @{

    CPUUSAGE = "$($AVGProc.Average)%"
    RAMUSAGE = "$($OS.MemoryUsage)%"
    HDDFree = "$($vol.'C PercentFree')%"
}

#enter your desired path here
 $result |out-file c:\averageusage11.csv
