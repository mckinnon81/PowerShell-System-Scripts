net stop spooler
Remove-Item -Path "$env:windir\system32\spool\printers\*" -include *.shd -whatif
Remove-Item -Path "$env:windir\system32\spool\printers\*" -include *.spl -whatif
net start spooler
