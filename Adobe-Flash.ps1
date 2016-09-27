# usage .\Flash.ps1

# create folders on target
New-Item -Path "c:\temp\Payload\" -type directory -Force

# Checks architecture
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth

# download newest redistributable flash player from Adobe
$source = "http://download.macromedia.com/get/flashplayer/current/licensing/win/install_flash_player_11_active_x.msi"
$destination = "c:\temp\Payload\install_flash_player_11_active_x.msi"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($source, $destination)

$source = "http://download.macromedia.com/get/flashplayer/current/licensing/win/install_flash_player_11_plugin.msi"
$destination = "c:\temp\Payload\install_flash_player_11_plugin.msi"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($source, $destination)


# terminate Windows Installer
Stop-Process -processname "wusa" -Force -ErrorAction SilentlyContinue
Stop-Process -processname "msiexec" -Force -ErrorAction SilentlyContinue


# to install the MSI packages
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\msiexec.exe /i c:\temp\Payload\install_flash_player_11_active_x.msi /q ALLUSERS=1")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}

$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\msiexec.exe /i c:\temp\Payload\install_flash_player_11_plugin.msi /q ALLUSERS=1")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}

# create mms.cfg
echo AutoUpdateDisable=1 | Out-File c:\Windows\System32\Macromed\Flash\mms.cfg
If($query.AddressWidth -eq 64) {echo AutoUpdateDisable=1 | Out-File C:\Windows\SysWOW64\Macromed\Flash\mms.cfg}


# cleanup installation files
Remove-Item "c:\temp\Payload\" -Recurse -Force -ErrorAction SilentlyContinue