#Variables for Email Notificaation

#Vaariaables for Email Settings


#Office 365 Authentication
$username="<email_address>"
$password=ConvertTo-SecureString "<password>"-AsPlainText -Force
$mycredentials = New-Object System.Management.Automation.PSCredential ($username, $password)

#For Office 365 Set to smtp.office365.com
#Set to SMTP Server or Local Exchange Server Name
$SMTPSERVER = "mx1.trio.local"

#Remove old files


#Get Computer Details
$computers = Get-ADComputer -Filter * -SearchBase "OU=Servers,OU=Computers,OU=Trio Trading,dc=trio,dc=local" | Select Name

$Computers = "WIN10PC"
#Import Computer Names
#Get System Boot Time and Host Name
foreach($computer in $computers)
{
	Write-Host "Getting System Details for" $computer -ForegroundColor Yellow
	$server1 = systeminfo /s $computer | find "System Boot Time"
	$server2 = systeminfo /s $computer | find "Host Name"

	$From = "helpdesk@triotrading.com.au"
	$To = "helpdesk@triotrading.com.au"
	$Subject = "Uptime Notification - $Computer"
	$Body = $server1 + $Server2

	Send-mailmessage -from $From -to $To -subject $Subject -body $Body  -smtpServer $SMTPSERVER -Credential $mycredentials

}

#Add "-UseSSL -Credential $mycredentials" for Office 365 Authentication, Remove for Local Exchange
