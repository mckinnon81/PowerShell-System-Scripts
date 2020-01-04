Start-Transcript -Path C:\scripts\Transcript.log

# Function to write the HTML Header to the file
Function writeHtmlHeader
{
param($fileName)
$date = ( get-date ).ToString('yyyy/MM/dd')
Add-Content $fileName "<html>"
Add-Content $fileName "<head>"
Add-Content $fileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $fileName '<title>ShdowProtect Report</title>'
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
add-content $fileName  "<font face='tahoma' color='#000000' size='5'><center><strong>ShadowProtect Report - $date</strong></center></font>"
add-content $fileName  "</td>"
add-content $fileName  "</tr>"

}

# Function to write the HTML Header to the file
Function writeTableHeader
{
param($fileName)
Add-Content $fileName "<tr bgcolor=#5F9EA0>"
Add-Content $fileName "<td><b>Server</b></td>"
Add-Content $fileName "<td><b>Time</b></td>"
Add-Content $fileName "<td><b>Version</b></td>"
Add-Content $fileName "<td><b>Status</b></td>"
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
param($fileName,$Server,$TimeGen,$Version,$Status)
if ($status -eq 'Warning')
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td >$Server</td>"
Add-Content $fileName "<td >$TimeGen</td>"
Add-Content $fileName "<td >$Version</td>"
Add-Content $fileName "<td  bgcolor='yellow' >$Status</td>"
Add-Content $fileName "</tr>"
}
elseif ($status -eq 'Failed')
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td >$Server</td>"
Add-Content $fileName "<td >$TimeGen</td>"
Add-Content $fileName "<td >$Version</td>"
Add-Content $fileName "<td  bgcolor='red' >$Status</td>"
Add-Content $fileName "</tr>"

}
elseif ($status -eq 'Successful')
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td >$Server</td>"
Add-Content $fileName "<td >$TimeGen</td>"
Add-Content $fileName "<td >$Version</td>"
Add-Content $fileName "<td  bgcolor='green' >$Status</td>"
Add-Content $fileName "</tr>"
}
}

#Global Variaables
$freeSpaceFileName = "C:\Scripts\ShadowProtect-Report.htm"
New-Item -ItemType file $freeSpaceFileName -Force | Out-Null

#Get List of Servers
$SP_SERVERS = @(
'PS-EX-01',
'PS-SQL-01'
)

writeHtmlHeader $freeSpaceFileName
writeTableHeader $freeSpaceFileName

$After = ((Get-Date).AddHours(-2))

foreach ($PC in $SP_SERVERS)
{
Write-Host "Getting Data from" $PC -foregroundcolor Yellow

$LOG = @(Get-EventLog -Computername $PC -LogName "Application" -After $After | Where-Object {$_.EventID -eq 1120 -or $_.EventID -eq 1121 -or $_.EventID -eq 1122 -or $_.EventID -eq 3 -or $_.EventID -eq 4 -or $_.EventID -eq 5 -and $_.Source -like "*ShadowProtect*" -and (Get-Date $_.TimeWritten) -gt ((Get-Date).AddHours(-24))} | Select MachineName,EventID,Source,TimeGenerated)

$LOG | foreach {
if ($_.EventID -eq '3' -or $_.EventID -eq '1120') {
  $Status = "Successful"
} ElseIf ($_.EventID -eq '5' -or $_.EventID -eq '1121') {
  $Status = "Failed"
} ElseIf ($_.EventID -eq '4' -or $_.EventID -eq '1122') {
	$Status = "Warning"
}

$Server = $_.MachineName
$TimeGen = $_.TimeGenerated
$Version = $_.Source

#write-host $Server $TimeGen $Version $Status
writeDiskInfo $freeSpaceFileName $Server $TimeGen $Version $Status

}
}

Add-Content $freeSpaceFileName "</table>"
writeHtmlFooter $freeSpaceFileName

#Email Details
$From = "sysop@poolsystems.com.au"
$To = "mmckinnon@zerolimit.com.au"
$Subject = "ShadowProtect Report - PoolSystems"

#Replace "-Raw" with "| Out-String" when using Powershell 2.0
$Body = Get-Content $freeSpaceFileName -Raw

#Office 365 Authentication
$username = "<email_address>"
$password = ConvertTo-SecureString "<password>" -AsPlainText -Force
$mycredentials = New-Object System.Management.Automation.PSCredential ($username, $password)

#For Office 365 Set to smtp.office365.com
#Set to SMTP Server or Local Exchange Server Name
$SMTPSERVER = "PS-EX-01"

#Add "-UseSSL -Credential $mycredentials" for Office 365 Authentication, Remove for Local Exchange
Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -BodyAsHtml -Priority High -SmtpServer $SMTPSERVER


#Remove files - Powershell 3.0+
remove-item $freeSpaceFileName -erroraction Ignore

#Remove old Files - Powershell 2.0
#rd $freeSpaceFileName

Stop-Transcript
