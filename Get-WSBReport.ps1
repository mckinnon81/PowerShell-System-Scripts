Start-Transcript -Path C:\Script\Get-WSBReport.log

#Windows Server 2012
Add-PsSnapin Windows.ServerBackup


#Email Details
$From = "<from_address>"
$To = "<to_address>"
$Subject = $env:computername+": Backup Report - "+(Get-Date)

#For Office 365 Set to smtp.office365.com
#Set to SMTP Server or Local Exchange Server Name
$SMTPSERVER = "smtp.office365.com"

#Office 365 Authentication
$username = "<email_address>"
$password = ConvertTo-SecureString "<password>"-AsPlainText -Force
$mycredentials = New-Object System.Management.Automation.PSCredential ($username, $password)

# Private Variables
$WBJob = Get-WBJob -Previous 1
$WBSummary = Get-WBSummary
$WBJobStartTime = $WBJob.StartTime
$WBJobEndTime = $WBJob.EndTime
#$WBJobSuccessLog = Get-Content -Path $WBJob.SuccessLogPath
#$WBJobFailureLog = Get-Content -Path $WBJob.FailureLogPath

# Change Result of 0 to Success in green text and any other result as Failure in red text
If ($WBSummary.LastBackupResultHR -eq 0) {
    $WBJobResult = "successful"
} Else {
    $WBJobResult = "failed"
}


#Email Body
$Body = @"
<!DOCTYPE html>
<html>
<head>
<title>$HTMLMessageSubject</title>
<style>
h1.successful {color:green;}
h1.failed {color:red;}
</style>
</head>
<body>
<h1 class="$WBJobResult">Backup $WBJobResult</h1>
Start: $WBJobStartTime<br>
Finished: $WBJobEndTime<br>
<br>
<p>Log:</p>
<br>
$WBJobLog
</body>
</html>
"@


##Add "-UseSSL -Credential $mycredentials" for Office 365 Authentication, Remove for Local Exchange
Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -BodyAsHtml -Priority High -SmtpServer $SMTPSERVER


Stop-Transcript
