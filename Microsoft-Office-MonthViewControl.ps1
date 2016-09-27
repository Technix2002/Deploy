# usage .\Office-MonthViewControl.ps1


# populating variables
$target = 'c:\temp\Payload'
$URL = 'http://activex.microsoft.com/controls/vb6/mscomct2.cab'
$file = 'mscomct2.cab'
$switches = "-F:*.* $target\$file c:\Windows\System32"


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# to expand cab file
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("C:\Windows\System32\expand.exe $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# to install INF file
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("C:\Windows\System32\rundll32.exe advpack.dll,LaunchINFSectionEx c:\Windows\System32\mscomct2.inf,,,4")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue