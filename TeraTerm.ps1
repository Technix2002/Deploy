# usage .\TeraTerm.ps1


# Checks architecture to set variables
$architecture = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($architecture.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
}

If($architecture.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
}


# poplulating more variables
$target = 'c:\temp\Payload'
$app = 'teraterm'
$version = '4.84'
$file = "$app-$version.exe"
$URL = "http://iij.dl.sourceforge.jp/ttssh2/61906/$file"
$switches = '/verysilent'
$appfolder = "C:\$ProgFiles\teraterm"


# uninstalls previous versions
If (Test-Path "$appfolder") {
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""$appfolder\unins000.exe"" /VERYSILENT /SUPPRESSMSGBOXES")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}
}


# create folder on target
New-Item -Path $target -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$target\$file $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# copies shortcut to desktop
Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Tera Term\Tera Term.lnk" -Destination "c:\Users\Public\Desktop" -Force


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue