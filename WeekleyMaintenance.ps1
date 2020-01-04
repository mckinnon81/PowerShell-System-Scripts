#Weekly Maintenance


#Create Restore Point
#Reboot Computer
#Delete Temp Files
#Empty Temp Folders
#Run Full Disk Cleanup unattended
#Reboot

# 1.creating the restore point
Checkpoint-Computer -Description "Weekly Maintanence" -RestorePointType "MODIFY_SETTINGS"
Write-Host "System Restore Point created successfully"




#3.Delete Temp Files

    $objShell = New-Object -ComObject Shell.Application
    $objFolder = $objShell.Namespace(0xA)

    $temp = get-ChildItem "env:\TEMP"
    $temp2 = $temp.Value

    $WinTemp = "c:\Windows\Temp\*"



# Remove temp files located in "C:\Users\USERNAME\AppData\Local\Temp"
    write-Host "Removing Junk files in $temp2." -ForegroundColor Magenta
    Remove-Item -Recurse  "$temp2\*" -Force -Verbose



# Remove Windows Temp Directory (Folder)
    write-Host "Removing Junk files in $WinTemp." -ForegroundColor Green
    Remove-Item -Recurse $WinTemp -Force

#5. Running Disk Clean up Tool
    write-Host " Running Windows disk Clean up Tool" -ForegroundColor Cyan
 cleanmgr /sagerun:1 | out-Null



    $([char]7)
    Sleep 1
    $([char]7)
    Sleep 1

    write-Host "Clean Up Task completed !"




#–AutoReboot




    #6.Reboot Computer

#Restart-Computer TODO - Syncro cannot currently reboot a computer from scripts.
