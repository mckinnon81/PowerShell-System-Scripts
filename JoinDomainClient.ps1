$COMPUTERNAME = read-host "Enter New Computer Name"
$DOMAIN = read-host "Enter Domain Name (ipg.local)"

Add-Computer -DomainName $DOMAIN -ComputerName $env:computername -newname $COMPUTERNAME
