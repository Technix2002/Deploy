# usage .\IE-SeperateProcesses.ps1


# populating variables
$target = 'c:\temp\Payload\' 
$loggedin = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem -erroraction silentlycontinue | Select-Object -Property Username
$username = Split-Path $loggedin.Username.ToString() -Leaf
$objUser = New-Object System.Security.Principal.NTAccount("corp.twcable.com", "$username")
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
$hkeys = 'HKEY_LOCAL_MACHINE','HKEY_USERS'
$keys = 'Software\Microsoft\Windows\CurrentVersion\Explorer'
$names = 'DesktopProcess','SeparateProcess'
$type = 'DWORD'
$value = '1'


# settings values in registry

    # logged in user
New-Item -Path Microsoft.PowerShell.Core\Registry::"HKEY_USERS\$strSID\$keys" -Name "BrowseNewProcess"


    # logged off users
Foreach ($user in $loggedoff) {

        # mounts each logged off user's registry
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\reg load ""HKLM\$user"" ""c:\Users\$user\ntuser.dat""") 
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}

New-Item -Path Microsoft.PowerShell.Core\Registry::"HKEY_LOCAL_MACHINE\$User\$keys" -Name "BrowseNewProcess"
}

    # all users
Foreach ($user in $allusers) {
Foreach ($hkey in $hkeys) {
Foreach ($name in $names) {Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$user\$keys" -Name $name -Type $type -Value $value -Force}
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$user\$keys\BrowseNewProcess" -Name "BrowseNewProcess" -Type String -Value yes -Force
}
}


# unmounts each user's registry
Foreach ($user in $users) {
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\reg unload ""HKLM\$user""") 
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}
}


# removes files
Remove-Item -Path $target -Recurse -Force