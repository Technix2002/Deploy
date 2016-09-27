# usage .\Template-Payload.ps1


# poplulating more variables
$ErrorActionPreference = "Stop"
$target = 'c:\temp\Payload'
$service = 'Spooler'
$spool = 'c:\windows\system32\spool\printers'


# create folder on target
New-Item -Path "$target" -type directory -Force


# stop spooler
Set-Service -name $service -Status Stopped -ErrorAction SilentlyContinue
Start-Sleep 10


# removes files
Try {
Remove-Item "$spool\*.*" -Recurse -Force -ErrorAction SilentlyContinue
}
Catch {
# catch? there is no catch!
}


# start spooler
Set-Service -name $service -Status Running
Start-Sleep 10


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force