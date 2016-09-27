# usage .\InternetExplorer9.ps1


# Checks architecture to set variables
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($query.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software'
$URL = 'http://download.microsoft.com/download/C/3/B/C3BF2EF4-E764-430C-BDCE-479F2142FC81/IE9-Windows7-x86-enu.exe'
$file = 'IE9-Windows7-x86-enu.exe'}

If($query.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node'
$URL = 'http://download.microsoft.com/download/C/1/6/C167B427-722E-4665-9A40-A37BC5222B0A/IE9-Windows7-x64-enu.exe'
$file = 'IE9-Windows7-x64-enu.exe'}


# poplulating more variables
$app = 'Internet Explorer'
$target = 'c:\temp\Payload'
$switches = '/quiet /norestart'


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# ends task on application
Stop-Process -processname "wusa" -Force
Stop-Process -processname "msiexec" -Force
Stop-Process -processname "iexplore" -Force


# uninstalls previous versions
Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%$app%'" | Foreach-Object { 
Write-Host "Uninstalling: $($_.Name)"
$rv = $_.Uninstall().ReturnValue 
if($rv -eq 0) {"$($_.Name) uninstalled successfully"}}


# to installs application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""$target\$file"" $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force