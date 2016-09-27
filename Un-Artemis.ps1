# Usage .\Un-Artemis.ps1


# setting variables
$target = 'c:\temp\Payload'
$loggedin = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem -erroraction silentlycontinue | Select-Object -Property Username
$username = Split-Path $loggedin.Username.ToString() -Leaf
$objUser = New-Object System.Security.Principal.NTAccount("$username")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
$strSID = $strSID.Value
$loggedoff = split-path "c:\Users\*" -Leaf -Resolve
    # function ToArray
function ToArray
{
  begin
  {
    $output = @(); 
  }
  process
  {
    $output += $_; 
  }
  end
  {
    return ,$output; 
  }
}
$allusers = $strSID, $loggedoff | ToArray


# ending taks on suspicious executables, deleting suspicious executables, removing run entries from user's registry
ForEach ($user in $loggedoff) {

    # mounts each logged off user's registry
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\reg load HKLM\$user ""c:\Users\$user\ntuser.dat""") 
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 2}

$profileroot = split-path "c:\Users\$user\*.exe" -Leaf -Resolve
$executable = $profileroot | ForEach-Object {$_.trimend('.exe')}
Foreach ($exe in $executable) {Stop-Process -processname "$exe" -Force} 
Remove-Item "c:\Users\$user\*.exe" -Force

$AppData = split-path "c:\Users\$user\AppData\*.exe" -Leaf -Resolve
$executable = $AppData | ForEach-Object {$_.trimend('.exe')}
Foreach ($exe in $executable) {Stop-Process -processname "$exe" -Force} 
Remove-Item "c:\Users\$user\AppData\*.exe" -Force
Remove-Item "c:\Users\$user\AppData\Local\Temp\*.*" -Force -Recurse
Remove-Item "c:\Users\$user\AppData\Local\Temp\*" -Force -Recurse
Remove-Item "c:\Users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*" -Force -Recurse
Remove-Item "c:\Users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Force -Recurse

$Local = split-path "c:\Users\$user\AppData\LocalLow\*.exe" -Leaf -Resolve
$executable = $Local | ForEach-Object {$_.trimend('.exe')}
Foreach ($exe in $executable) {Stop-Process -processname "$exe" -Force}
Remove-Item "c:\Users\$user\AppData\LocalLow\*.exe" -Force

$Roaming = split-path "c:\Users\$user\AppData\Roaming\*.exe" -Leaf -Resolve
$executable = $Roaming | ForEach-Object {$_.trimend('.exe')}
Foreach ($exe in $executable) {Stop-Process -processname "$exe" -Force}
Remove-Item "c:\Users\$user\AppData\Roaming\*.exe" -Force

# removes user's run values 
$Keys = "HKEY_LOCAL_MACHINE\$user","HKEY_USERS\$strSID"
Foreach ($Keyvalue in $Keys) {Remove-Item -Path Microsoft.PowerShell.Core\Registry::"$Keyvalue\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse}
}


# unmounts each user's registry
ForEach ($user in $loggedoff) {
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\reg unload HKLM\$user") 
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 2}}


# removes toolbars
$bars = 'Google','Yahoo','AOL','MySerach','Bar'
Foreach ($bar in $bars) {
Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%$bar%'" | Foreach-Object { 
Write-Host "Uninstalling: $($_.Name)"
$rv = $_.Uninstall().ReturnValue 
if($rv -eq 0) {"$($_.Name) uninstalled successfully"}}
}


# removes leftovers
Remove-Item -Path $target -Recurse -Force