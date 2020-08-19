# script created to pull Average CPU, RAM and HDD usage
# the details are for the comptuer that run this script on (For single computer)

Param (
		[Parameter(Mandatory = $true)]
		[string]
		$ComputerName
  )


#$AVGProc = Get-WmiObject -ComputerName $ComputerName win32_processor | Measure-Object -property LoadPercentage -Average | Select Average
#$OS = gwmi -ComputerName $ComputerName -Class win32_operatingsystem  | Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}
#Get-WmiObject -ComputerName $ComputerName -Class win32_Volume -Filter "DriveLetter = 'C:'" | Select-object @{Name = "C PercentFree"; Expression = {“{0:N2}” -f  (($_.FreeSpace / $_.Capacity)*100) } }
Get-CimInstance -Class CIM_LogicalDisk -ComputerName $ComputerName | Where-Object DriveType -EQ '3' | Select-Object @{Name="Size(GB)";Expression={"{0:N2}" -F ($_.size/1gb)}}, @{Name="Free Space(GB)";Expression={"{0:N2}" -F ($_.freespace/1gb)}}, @{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}}
