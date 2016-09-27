# usage .\IE-Cleanup.ps1


# ends task on Internet Explorer
Stop-Process -processname "iexplore" -Force
Stop-Process -processname "chrome" -Force


# deletes temporary Internet files across all profiles
remove-item "c:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*" -recurse -force
remove-item "c:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -recurse -force
remove-item "c:\Users\*\AppData\Local\Google\Chrome\*\*\Cache\*.*" -recurse -force
remove-item "c:\Users\*\AppData\Local\Google\Chrome\*\*\Cache\*" -recurse -force


# removes temporary Java files
Remove-Item "c:\Users\*\AppData\LocalLow\Sun\Java\Deployment\cache\*\*\*.*" -Recurse -Force
Remove-Item "c:\Users\*\AppData\LocalLow\Sun\Java\Deployment\cache\*\*" -Recurse -Force


# removes Toolbars
Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "Toolbar"}
$app.Uninstall()


# removes files
Remove-Item "c;\temp\Payload" -Recurse -Force