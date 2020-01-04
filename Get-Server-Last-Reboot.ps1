#Variables for Email Notificaation

#Vaariaables for Email Settings
$From = "<from_address>"
$To = "<to_address>"
$Subject = "Update Reboot Notification - Servers"
$Bodymsg = "See attached for restart times for affected servers."
$Body = $Bodymsg

#Office 365 Authentication
$username="<email_address>"
$password=ConvertTo-SecureString "<password>"-AsPlainText -Force
$mycredentials = New-Object System.Management.Automation.PSCredential ($username, $password)

#For Office 365 Set to smtp.office365.com
#Set to SMTP Server or Local Exchange Server Name
$SMTPSERVER = "smtp.office365.com"

#Remove old files
remove-item server-info.txt -erroraction Ignore
remove-item servers.csv -erroraction Ignore

#Get Computer Details
get-adcomputer -filter {OperatingSystem -like "Windows Server*" -and Name -notlike "*-P" -and Name -notlike "IPG*"} -Property * | Select Name | Export-CSV -Path .\servers.csv -NoTypeInformation

#Import Computer Names
$CSV = import-csv servers.csv

#Get System Boot Time and Host Name
foreach($item in $CSV)
{
	$comp = $item.name
	Write-Host "Getting System Details for" $item.name -ForegroundColor Yellow
	$server1 = systeminfo /s $comp | find "System Boot Time"
	$server2 = systeminfo /s $comp | find "Host Name"
	write-output "$server2;$server1" >> server-info.txt
}

#Add "-UseSSL -Credential $mycredentials" for Office 365 Authentication, Remove for Local Exchange
Send-mailmessage -from $From -to $To -subject $Subject -body $Body -attachments server-info.txt -smtpServer $SMTPSERVER -Credential $mycredentials -UseSSL
