# usage .\OfflineFilesDisable.ps1


# populating variables
$target = 'c:\temp\Payload\'
$service = 'CscService'
$start = 'Disable'


# stop process
Stop-Process -Name $service -Force
Set-Service -Name $service -StartupType $start


# remove files
Remove-Item -Path $target -Recurse -Force