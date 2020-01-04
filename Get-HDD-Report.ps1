Start-Transcript -Path C:\Scripts\Get-HDD-Report.log

Import-Module ActiveDirectory

# Function to write the HTML Header to the file
Function writeHtmlHeader
{
param($fileName)
$date = ( get-date ).ToString('dd/MM/yyyy')
Add-Content $fileName "<html>"
Add-Content $fileName "<head>"
Add-Content $fileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $fileName '<title>DiskSpace Report</title>'
add-content $fileName '<STYLE TYPE="text/css">'
add-content $fileName  "<!--"
add-content $fileName  "td {"
add-content $fileName  "font-family: Verdana;"
add-content $fileName  "font-size: 11px;"
add-content $fileName  "border-top: 1px solid #999999;"
add-content $fileName  "border-right: 1px solid #999999;"
add-content $fileName  "border-bottom: 1px solid #999999;"
add-content $fileName  "border-left: 1px solid #999999;"
add-content $fileName  "padding-top: 0px;"
add-content $fileName  "padding-right: 0px;"
add-content $fileName  "padding-bottom: 0px;"
add-content $fileName  "padding-left: 0px;"
add-content $fileName  "}"
add-content $fileName  "body {"
add-content $fileName  "margin-left: 5px;"
add-content $fileName  "margin-top: 5px;"
add-content $fileName  "margin-right: 0px;"
add-content $fileName  "margin-bottom: 10px;"
add-content $fileName  ""
add-content $fileName  "-->"
add-content $fileName  "</style>"
Add-Content $fileName "</head>"
Add-Content $fileName "<body>"
add-content $fileName  "<table width='100%'>"
add-content $fileName  "<tr bgcolor='#5F9EA0'>"
add-content $fileName  "<td colspan='9' height='25'  width=5% align='left'>"
add-content $fileName  "<font face='Verdana' color='#000000' size='5'><center><strong>DiskSpace Report - $date</strong></center></font>"
add-content $fileName  "</td>"
add-content $fileName  "</tr>"

}

# Function to write the HTML Header to the file
Function writeTableHeader
{
param($fileName)
Add-Content $fileName "<tr bgcolor=#5F9EA0>"
Add-Content $fileName "<td><b>Server</b></td>"
Add-Content $fileName "<td><b>Drive</b></td>"
Add-Content $fileName "<td><b>Drive Label</b></td>"
Add-Content $fileName "<td><b>Total Capacity(GB)</b></td>"
Add-Content $fileName "<td><b>Used Capacity(GB)</b></td>"
Add-Content $fileName "<td><b>Free Space(GB)</b></td>"
Add-Content $fileName "<td><b>FreeSpace % </b></td>"
Add-Content $fileName "<td><b>Status </b></td>"
Add-Content $fileName "</tr>"
}

Function writeHtmlFooter
{
param($fileName)

Add-Content $fileName "</body>"
Add-Content $fileName "</html>"
}

Function writeDiskInfo
{
param($fileName,$server,$DeviceID,$VolumeName,$TotalSizeGB,$UsedSpaceGB,$FreeSpaceGB,$FreePer,$status)
if ($status -eq 'warning')
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td >$server</td>"
Add-Content $fileName "<td >$DeviceID</td>"
Add-Content $fileName "<td >$VolumeName</td>"
Add-Content $fileName "<td >$TotalSizeGB</td>"
Add-Content $fileName "<td >$UsedSpaceGB</td>"
Add-Content $fileName "<td >$FreeSpaceGB</td>"
Add-Content $fileName "<td  bgcolor='yellow' >$FreePer</td>"
Add-Content $fileName "<td >$status</td>"
Add-Content $fileName "</tr>"
}
elseif ($status -eq 'critical')
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td >$server</td>"
Add-Content $fileName "<td >$DeviceID</td>"
Add-Content $fileName "<td >$VolumeName</td>"
Add-Content $fileName "<td >$TotalSizeGB</td>"
Add-Content $fileName "<td >$UsedSpaceGB</td>"
Add-Content $fileName "<td >$FreeSpaceGB</td>"
Add-Content $fileName "<td bgcolor='red' >$FreePer</td>"
Add-Content $fileName "<td >$status</td>"
Add-Content $fileName "</tr>"

}
elseif ($status -eq 'low')
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td >$server</td>"
Add-Content $fileName "<td >$DeviceID</td>"
Add-Content $fileName "<td >$VolumeName</td>"
Add-Content $fileName "<td >$TotalSizeGB</td>"
Add-Content $fileName "<td >$UsedSpaceGB</td>"
Add-Content $fileName "<td >$FreeSpaceGB</td>"
Add-Content $fileName "<td bgcolor='orange' >$FreePer</td>"
Add-Content $fileName "<td >$status</td>"
Add-Content $fileName "</tr>"
}
elseif ($status -eq 'good')
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td >$server</td>"
Add-Content $fileName "<td >$DeviceID</td>"
Add-Content $fileName "<td >$VolumeName</td>"
Add-Content $fileName "<td >$TotalSizeGB</td>"
Add-Content $fileName "<td >$UsedSpaceGB</td>"
Add-Content $fileName "<td >$FreeSpaceGB</td>"
Add-Content $fileName "<td bgcolor='green' >$FreePer</td>"
Add-Content $fileName "<td >$status</td>"
Add-Content $fileName "</tr>"
}
}

#Global Variaables
$freeSpaceFileName = "FreeSpace.htm"
New-Item -ItemType file $freeSpaceFileName -Force | Out-Null

writeHtmlHeader $freeSpaceFileName
writeTableHeader $freeSpaceFileName

#Get List of Servers
$ADCOMPUTER = @(get-adcomputer -filter {OperatingSystem -like "Windows*Server*"} -Property * | Select Name)

foreach ($PC in $ADCOMPUTER)
{
$clowth = 25
$cwarnth = 15
$ccritth = 10
$diskinfo = get-WmiObject win32_logicaldisk -ComputerName $PC.Name -Filter "DriveType = '3'"

foreach ($disk in $diskinfo)
{
	If ($disk.Size -gt 0) {$percentFree = [Math]::round((($disk.freespace/$disk.size) * 100))} Else {$percentFree = 0}
	$server=$disk.__Server
	$DeviceID=$disk.DeviceID
	$VolumeName=$disk.VolumeName
	$TotalSizeGB=[math]::Round(($disk.Size /1GB),2)
	$FreeSpaceGB=[math]::Round(($disk.FreeSpace / 1GB),2)
	$UsedSpaceGB=[math]::Round((($disk.Size - $disk.FreeSpace)/1GB),2)
	$FreePer=("{0:P}" -f ($disk.FreeSpace / $disk.Size))

	#Determine if disk needs to be flagged for warning or critical alert
  If ($percentFree -le  $ccritth) {
  	$status = "Critical"
  } ElseIf ($percentFree -gt $ccritth -AND $percentFree -le $cwarnth) {
    $status = "Warning"
  } ElseIf ($percentFree -ge $cwarnth -AND $percentFree -lt $clowth) {
    $status = "Low"
  } Else {
    $status = "Good"
  }

	#write-host  $server $DeviceID  $VolumeName $TotalSizeGB  $UsedSpaceGB $FreeSpaceGB $FreePer $status
	writeDiskInfo $freeSpaceFileName $server $DeviceID $VolumeName $TotalSizeGB  $UsedSpaceGB $FreeSpaceGB $FreePer $status
}
}

Add-Content $freeSpaceFileName "</table>"
writeHtmlFooter $freeSpaceFileName

#Email Details
$From = "sysop@amcs.org.au"
$To = "clientreports@zerolimit.com.au"
$Subject = "Disk Usage Report - Servers"

#Replace "-Raw" with "| Out-String" when using Powershell 2.0
#
if ($PSVersionTable.PSVersion.Major -eq 2)
{
	$Body = Get-Content $freeSpaceFileName | Out-String
}
else
{
	$Body = Get-Content $freeSpaceFileName -Raw
}

#Office 365 Authentication
$username = "<email_address>"
$password = ConvertTo-SecureString "<password>"-AsPlainText -Force
$mycredentials = New-Object System.Management.Automation.PSCredential ($username, $password)

#For Office 365 Set to smtp.office365.com
#Set to SMTP Server or Local Exchange Server Name
$SMTPSERVER = "mail.bigpond.com"

#Add "-UseSSL -Credential $mycredentials" for Office 365 Authentication, Remove for Local Exchange
Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -BodyAsHtml -Priority High -SmtpServer $SMTPSERVER

#Remove old files - Powershell 3.0+
#remove-item servers.csv -erroraction Ignore
#remove-item $freeSpaceFileName -erroraction Ignore

#Remove old Files - Powershell 2.0
rd $freeSpaceFileName

Stop-Transcript
