if ((Get-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue) -eq $null) {Add-PsSnapin VeeamPSSnapIn}

$outputfile = "$env:UserProfile\Desktop\backupedvms.csv"

$vbrsessions = Get-VBRBackupSession | Where-Object {$_.JobType -eq "Backup" -and $_.EndTime -ge (Get-Date).addhours(-24)}
$backupedvms = foreach ($session in $vbrsessions) {$session.gettasksessions()| Select Name, Status, Jobname } 
$setarray = @("Name", "Status", "JobName")
$backupedvms | Select-Object -Property $setarray | Export-CSV -Encoding "UTF8" -NoTypeInformation $outputfile