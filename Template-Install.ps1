# ============================================================
# Install APPLICATION NAME & VERSION
# ============================================================
# Date:	
# Author:	
# ============================================================
# Script Details:
#	
#	EXIT CODES
#		   0 - SUCCESSFUL
#		   1 - Invalid ProgramType; x86 OR x64
#		   5 - APPLICATION is running
#		   6 - Incorrect OS Type (x86 OS with x64 Application)
#		  49 - Windows XP
#		1605 - Product Not Installed
#		1641 - Install Successful Computer Rebooted
#		3010 - Install Successful Reboot Required
# ============================================================


# ============================================================
# 		Variable Declarations
# ============================================================
$ProgramType = $null # "change $null value to x86 or x64"
$URL = $null # "change $null to location of file download"
$Installer = $null # "change $null to installation file name"
$Switches = $null # "change $null to extra switches for installation of .exe installers"
$Transform = $null # "change $null to desired MSI transforms file"
$DesktopShortcut = $null # "change $null value to name of shortcut without extension to remove Desktop shortcut"
$RemoveBeforeInstall = $null # "change $null value to Y to remove based on DisplayName from the installer or change to product name to remove" 
$SetPermissions = $null # "change $null value to application's path to set permissions"
$RegistryKey = $null # "change $null value to Registry Key(s) of application being installed to edit registry"
$RegistryValue = $null # "change $null value to Registry Value to edit registry"
$ValueType = $null # "change $null value to Registry Value Type to edit registry"
$ValueData = $null # "change $null value to Registry Value Data to edit registry"


# ============================================================
# 		Static Variables
# ============================================================
$ErrorActionPreference = "Stop"
$OS = (Get-WmiObject Win32_OperatingSystem).Name.ToString()
$BitType = (Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth).AddressWidth.ToString()
$InstallSource = 'c:\temp\Payload'

    # creates installation surce folder
    New-Item -Path "$InstallSource" -ItemType Directory -Force -ErrorAction SilentlyContinue

$loggedin = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem -erroraction silentlycontinue | Select-Object -Property Username | Split-Path -Leaf | ForEach-Object {$_.toString() -replace [regex]::Escape('}'), ''}
    Try {
$SID = New-Object System.Security.Principal.NTAccount("", "$loggedin") | Foreach-Object {$_.Translate([System.Security.Principal.SecurityIdentifier])} | Select-Object -Property Value | ForEach-Object {$_.Value}
    }
    Catch {
# catch? there is no catch
    }
$loggedoff = split-path "c:\Users\*" -Leaf -Resolve
    
    If (($BitType -match "64") -and ($ProgramType -match "x86")) {
$ProgramFolder = ${env:ProgramFiles(x86)}
$CommonFolder = ${env:CommonProgramFiles(x86)}
$SoftwareKey = 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node'
    }
    
    Else {
$ProgramFolder = ${env:ProgramFiles}
$CommonFolder = $env:CommonProgramFiles
$SoftwareKey = 'HKEY_LOCAL_MACHINE\SOFTWARE'
}

$StartMenu = 'C:\ProgramData\Microsoft\Windows\Start Menu'

    If ($Transform) {
$Transforms = 'TRANSFORMS=' + "$InstallSource\$Transform"
    }
    Else {
$Transforms = $null
    }


$LogFolder = 'C:\ProgramData\Symantec\SoftwareInstall'
If ($Installer -match ".msi") {$end = '.msi'}
If ($Installer -match ".exe") {$end = '.exe'}
$Log = $Installer | ForEach-Object {$_.trimend("$end")} 
$Log = $Log + ".log"


# ============================================================
# 		Functions
# ============================================================

    # ToArray function
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

    # download from WWW
    function Get-FromWWW {
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$InstallSource\$Installer")
}
If ($URL) {
Get-FromWWW
}

        # Getting details from Installer function
    Function Get-MSIFileInformation {
param(
[IO.FileInfo]$Path,
[ValidateSet("ProductCode","ProductVersion","ProductName")]
[string]$Property
)
try {
    $WindowsInstaller  = New-Object -ComObject WindowsInstaller.Installer
    $MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase","InvokeMethod",$Null,$WindowsInstaller,@($Path.FullName,0))
    $Query = "SELECT Value FROM Property WHERE Property = '$("$Property")'"
    $View = $MSIDatabase.GetType().InvokeMember("OpenView","InvokeMethod",$null,$MSIDatabase,($Query))
    $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
    $Record = $View.GetType().InvokeMember("Fetch","InvokeMethod",$null,$View,$null)
    $Value = $Record.GetType().InvokeMember("StringData","GetProperty",$null,$Record,1)
    return $Value
} 
catch {
    Write-Output $_.Exception.Message
}
}
If ($end -match ".msi") {
$ProductCode = Get-MSIFileInformation -Path "$InstallSource\$Installer" -Property ProductCode
$ProductVersion = Get-MSIFileInformation -Path "$InstallSource\$Installer" -Property ProductVersion
$DisplayName = Get-MSIFileInformation -Path "$InstallSource\$Installer" -Property ProductName
}
    # Getting details from .exe installer
If ($end -match ".exe") {
$ProductVersion = (Get-ItemProperty -Path "$InstallSource\$Installer" -Name VersionInfo).VersionInfo.ProductVersion.ToString()
$DisplayName = (Get-ItemProperty -Path "$InstallSource\$Installer" -Name VersionInfo).VersionInfo.ProductName.ToString()
}

    # Remove application
    function Remove-Application {
[CmdletBinding()]
param (
     [string] $Application
     )
Try {
    Stop-Process -processname $Application -Force -ErrorAction SilentlyContinue
    Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%$Application%'" | Foreach-Object { 
    Write-Host "Uninstalling: $($_.Name)"
    $rv = $_.Uninstall().ReturnValue 
    If($rv -eq 0) {"$($_.Name) uninstalled successfully"}
    }
}
    Catch {
    # catch? there is no catch!
    }
}

    # Permissions function
Function Set-Permissions {
[CmdletBinding()]
     param (
     [string] $FolderPath
     )
$Perms=([WMICLASS]"root\cimv2:win32_Process").create("c:\Windows\System32\ICACLS.exe ""$FolderPath"" /grant ""NT AUTHORITY\Authenticated Users"" :(OI)(CI)M")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($Perms.ProcessID)'"){start-sleep -seconds 5}
}

    # String to binary function
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


# ============================================================
# 		Prerequisite Checks
# ============================================================

    # Quit if Windows XP
If ($OS -match "XP") {
Exit 49
}

    # Quit if installing 64 bit application on 32 bit Operating System
If ($ProgramType -match "x64") {
If ($BitType -match "32") { 
Exit 6
}
}

    # Quit if Application is running
If ($DisplayName) {
    If (Get-Process -Name $DisplayName -ErrorAction SilentlyContinue) {
    Exit 5
    }
}


    # If "RemoveBeforeInstall" is set to yes, then uninstall based on Installer's Display Name. If set to Application name, then uninstall all versions by name given.
If ($RemoveBeforeInstall -match "Y") {
    If ($DisplayName) {
Remove-Application -Application $DisplayName
}
    Else {
If ($RemoveBeforeInstall) {
    Remove-Application -Application $RemoveBeforeInstall
    }
    }
}


# ============================================================
# 		Install
# ============================================================

    # end task on processes
    If ($Processes) {
    Foreach ($Process in $Processes) {
    Try {
    Stop-Process -Name $Process -Force -ErrorAction SilentlyContinue
        }
        Catch {
        # catch? there is no catch!
        }
        }
    }

    # Install application
If ($Installer -match ".msi") {
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\Windows\System32\MSIExec.exe /QN /I ""$InstallSource\$Installer"" $Transforms $Switches /NORESTART /L* ""$LogFolder\$Log""")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}
}

If ($Installer -match ".exe") {
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""$InstallSource\$Installer"" $Switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}
}


# ============================================================
# 		Post install tasks
# ============================================================

    # If "DesktopShortcut" set to value
If ($DesktopShortcut) {
Try {
Remove-Item -Path "c:\Users\*\Desktop\$DesktopShortcut.lnk" -Force -ErrorAction SilentlyContinue
}
Catch {
# catch? there is no catch!
}
}

    # If "RegistryKey" is set to a value
If ($RegistryKey) {
New-Item -Path Microsoft.PowerShell.Core\Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Policies" -Name $RegistryKey -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\$RegistryKey" -Name "$RegistryValue" -Type $ValueType -Value $ValueData -Force -ErrorAction SilentlyContinue
}

    # If "SetPermissions" is set to name of folder
If ($SetPermissions) {
Set-Permissions -FolderPath $SetPermissions        
}


# ============================================================
# 		Exiting with MSI install return value
# ============================================================
Exit $NewProc.ProcessId