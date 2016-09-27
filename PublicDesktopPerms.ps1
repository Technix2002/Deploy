# usage .\PublicDesktopPerms.ps1

# sets permissions on Public\Desktop to allow for icons to be removed
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""c:\Users\Public\Desktop"" /t /e /p Users:F")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}

# cleanup installation files
Remove-Item "c:\temp\Payload\" -Recurse -Force