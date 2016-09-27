# .\SpyAdBlocker.ps1


# Checks architecture to set Program Files
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($query.AddressWidth -eq 32) {$ProgFiles = "Program Files"}
If($query.AddressWidth -eq 64) {$ProgFiles = "Program Files (x86)"}


# poplulating variables
$script = 'SpyAdBlocker.ps1'
$HOSTS = '77u/IyB1c2FnZSAuXEhPU1RTLnBzMSBkb3dubG9hZHMgSE9TVFMgZmlsZSB0byBjOlxXaW5kb3dzXFN5c3RlbTMyXGRyaXZlcnNcZXRjXEhPU1RTDQoNCg0KIyBwb3BsdWxhdGluZyB2YXJpYWJsZXMNCiRVUkwgPSAnaHR0cDovL3dpbmhlbHAyMDAyLm12cHMub3JnL2hvc3RzLnR4dCcNCg0KDQojIGNoZWNraW5nIGNvbm5lY3Rpdml0eQ0KJGJpdCA9ICRmYWxzZSANCndoaWxlICggJGJpdCAtZXEgJGZhbHNlICl7JHBpbmcgPSBUZXN0LUNvbm5lY3Rpb24gLUNvdW50IDMgIndpbmhlbHAyMDAyLm12cHMub3JnIiAtUXVpZXQgICAgDQokYml0ID0gJHBpbmcNCmlmICgkcGluZyAtbmUgJHRydWUpe1N0YXJ0LVNsZWVwIDEwfX0NCg0KDQojIGRvd25sb2FkIEhPU1RTIGZpbGUNCmlmICggJGJpdCAtZXEgJHRydWUgKXsNCiR3YyA9IE5ldy1PYmplY3QgU3lzdGVtLk5ldC5XZWJDbGllbnQNCiR3Yy5Eb3dubG9hZEZpbGUoJFVSTCwgImM6XFdpbmRvd3NcU3lzdGVtMzJcZHJpdmVyc1xldGNcSE9TVFMiKX0='
$file = 'HOSTS.ps1'
$target = "c:\$ProgFiles\HOSTS"
$URL = 'http://winhelp2002.mvps.org/hosts.txt'
$program = 'C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe'
$description = "HOSTS to avoid Spy-Adware"
$applnkname = 'SpyAdBlocker.lnk'
$arguments = "-ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File ""$target\$file"""
$lnklocation = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup'


# reassembling payloaded file
function Convert-StringToBinary {
     [CmdletBinding()]
     param (
           [string] $InputString
         , [string] $FilePath = ('{0}\{1}' -f $env:TEMP, [System.Guid]::NewGuid().ToString())
     )
 
    try {
         if ($InputString.Length -ge 1) {
             $ByteArray = [System.Convert]::FromBase64String($InputString);
             [System.IO.File]::WriteAllBytes($FilePath, $ByteArray);
         }
     }
     catch {
         throw ('Failed to create file from Base64 string: {0}' -f $FilePath);
     }
 
    Write-Output -InputObject (Get-Item -Path $FilePath);
 }
# reassamble string to file 
New-Item -Path "$target" -type directory -Force
$TargetFile = Convert-StringToBinary -InputString $HOSTS -FilePath "$target\$file";


# checking connectivity
$bit = $false 
while ( $bit -eq $false ){$ping = Test-Connection -Count 3 "winhelp2002.mvps.org" -Quiet    
$bit = $ping
if ($ping -ne $true){Start-Sleep 10}}


# download HOSTS file
if ( $bit -eq $true ){
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "c:\Windows\System32\drivers\etc\HOSTS")}


# creates new shortcut
$appfolder = Split-Path $program -Parent
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$lnklocation\$applnkname")
$Shortcut.TargetPath = "$program"
$Shortcut.IconLocation = "$program"
$shortcut.Arguments = "$arguments"
$Shortcut.Description ="$description"
$Shortcut.WorkingDirectory = "$appfolder"
$Shortcut.Save()