# .\Push.ps1

$ErrorActionPreference = "Stop"


# center text, credit for this is here: http://project500.squarespace.com/journal/2014/1/5/powershell-centering-console-text
Function Write-Centered {
    Param(  [string] $message,
            [string] $color = "black")
    $offsetvalue = [Math]::Round(([Console]::WindowWidth / 2) + ($message.Length / 2))
    Write-Host ("{0,$offsetvalue}" -f $message) -ForegroundColor $color
}


# greetings ladies and gentlemen (AYBABTU!)
Write-Centered "I present to you a localized deployment solution based on PowerShell and PSExec." -Color Green
Write-Centered "If you like my work, please contact me at:" -Color Green
Write-Centered "doyouknow.brad@gmail.com or (614) 585-9402. -Brad-" -Color Green
Write-Host " " -ForegroundColor Black


# flushing DNS and clearing arpcache, importing AD module
Write-Host "flushing DNS and clearing ARP Cache of local computer" -ForegroundColor Yellow
Write-Host "to purge stale local DNS and ARP cache records" -ForegroundColor Yellow
Write-Host " " -ForegroundColor Black
Try {
c:\windows\system32\ipconfig.exe /flushdns 2>&1 | Out-Null
c:\windows\system32\netsh.exe int ip delete arpcache 2>&1 | Out-Null
$Env:ADPS_LoadDefaultDrive=0
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
}
Catch {
# catch? there is no catch!
}


# setting some variables
$tech = [Security.Principal.WindowsIdentity]::GetCurrent().Name 
Try {
$domain = (Get-ADDomain).NetBIOSName
}
Catch {
# catch? there is no catch!
}
If ($domain) {
write-host "Domain is $domain" -ForegroundColor Green
Write-Host "Please insure that $tech has admin rights to the remote computer." -ForegroundColor White
Write-Host " " -ForegroundColor Black
}
    Else {
    Write-Host "Running from a host not joined to a domain!" -ForegroundColor Red
    Write-Host "Please insure that $tech has admin rights to the remote computer." -ForegroundColor White
    Write-Host " " -ForegroundColor Black
}
$date = Get-Date
$date = $date.ToString()
$tech = Split-Path $tech -Leaf
$path2script = $pwd.Path.ToString()


# test local computer for existence of PSExec
$psexec = Test-Path -Path "$path2script\psexec.exe"
If ($psexec -ne "True") {
$wc = New-Object System.Net.WebClient
$wc.DownloadFile("http://download.sysinternals.com/files/PSTools.zip", "$path2script\PSTools.zip")

$shell = new-object -com shell.application
 $zip = $shell.NameSpace("$path2script\PSTools.zip")
 foreach($item in $zip.items())
 {
 $shell.Namespace(“$path2script”).copyhere($item, 0x14)
 }

}


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

# Dialogue to get computer name(s)
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$comps = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a computer name or provide path to list in TXT format")
If ($comps) {
If ($comps -match ".txt") {
$computers = Get-Content -Path $comps}
Else {$computers = $comps}}
Else {
write-host "no computer(s) were provided" -ForegroundColor Red
write-host "terminating push" -ForegroundColor Red
Start-Sleep -Seconds 10
Exit
}

Foreach ($computer in $computers) {
If (test-connection $computer -quiet -count 1) {

Try {
$NAC = (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $computer -Namespace "root\CIMV2" -Property IPAddress -ErrorAction SilentlyContinue).IPAddress
}
Catch {
$NAC = [System.Net.Dns]::GetHostAddresses($computer).IPAddressToString
}


Try {
# model

$ComputerInfo = Get-WMIObject -ComputerName $computer -Class Win32_ComputerSystem -erroraction silentlycontinue
        New-Object PSObject -Property @{  
	    'Model'	       = $ComputerInfo.Model}

$model = $ComputerInfo.Model.ToString()

# login info
$FQuser = Get-WmiObject -ComputerName $computer -Namespace root\cimv2 -Class Win32_ComputerSystem -erroraction silentlycontinue 
$loggedin = $FQuser.Username.ToString()
$user = Split-Path $loggedin -Leaf
$logonui = Get-Process -ComputerName $computer -Name LogonUI -erroraction silentlycontinue

# get IE version
$wmi = [wmiclass]"\\$computer\root\default:stdRegProv"
$IE = ($wmi.GetStringValue('2147483650','SOFTWARE\Microsoft\Internet Explorer','Version')).svalue


# get Office version
  $version = 0
  $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)

  $reg.OpenSubKey('software\Microsoft\Office').GetSubKeyNames() |% {
    if ($_ -match '(\d+)\.') {
      if ([int]$matches[1] -gt $version) {
        $version = $matches[1]
      }
    }    
  }
  if ($version) {
      $Office = "$version"
    If (($Office -eq "14") -or ($Office -eq "15")) {
    $Office = 'Professional 2010'}
    If ($Office -eq "12") {
    $Office = 'Professional 2007'}
    }
    else {
      $Office = "not installed"
  }


# writing results to screen
write-host "Installed Applications:" -ForegroundColor DarkGreen
write-host "Internet Explorer version - $IE"
write-host "Microsoft Office version - $Office"
Write-Host " " -ForegroundColor Black
}
Catch {
# catch? there is no catch!
}
If ($loggedin) {
If ($logonui.ProcessName -match "LogonUI") {
write-host "$computer is online and is locked by $loggedin" -ForegroundColor Green
Write-Host " " -ForegroundColor Black
Clear-Variable logonui
}
Else {
write-host "$computer is online and is logged in by $loggedin" -ForegroundColor Green
Write-Host " " -ForegroundColor Black
}
}
Else {
write-host "$computer is online" -ForegroundColor Green
Write-Host " " -ForegroundColor Black
}
Set-Service -name SharedAccess -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Set-Service -name MpsSvc -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
$on +=$computer|toArray
}
Else {
write-host "$computer is offline" -ForegroundColor Red
Write-Host " " -ForegroundColor Black
$shell = new-object -comobject "WScript.Shell"
If ($offline -match "6") {write-host """wait for offline computer"" flag set to ""yes""" -ForegroundColor Green}
Else {
$offline = $shell.popup("Do you want to wait for computer(s) to be online?",0,"$computer is offline",4+32)}
$off +=$computer|toArray
}
If ($offline -match "7") {
echo "$computer is offline on $date by $tech"|Out-file -FilePath "\\mwrfnp01\shared$\MW Region IT\Software\PS\offline.txt" -Append
}
}
Clear-Variable computers

$computers = $on
If ($offline -match "6") {
$computers += $off|ToArray}

If ($offline -match "7") {
If ($on -eq $null) {
write-host "found no online computer(s)" -ForegroundColor Red
write-host "flag to wait for offline computer(s) was set to ""no""" -ForegroundColor Red
write-host "sent computer(s) name(s) to offline log file" -ForegroundColor Red
write-host "terminating push" -ForegroundColor Red
Start-Sleep -Seconds 10
Exit}
}


# select an action dialog
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select an action"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objListBox.SelectedItem;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$x=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please select an action:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80

[void] $objListBox.Items.Add("Run script(s)")
[void] $objListBox.Items.Add("Reboot computer(s)")
[void] $objListBox.Items.Add("Shutdown computer(s)")
If ($domain) {  
[void] $objListBox.Items.Add("Delete Outlook Temp Files")
}
[void] $objListBox.Items.Add("Disable Windows Firewall")
[void] $objListBox.Items.Add("Disable Windows Offline Files")

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$x

$action = $objListBox.SelectedItem


# disable Windows Firewall
If ($action -match "Firewall") {
Foreach ($computer in $computers) {
$bit = $false 
while ( $bit -eq $false ){$ping = Test-Connection -Count 1 "$computer" -Quiet    
$bit = $ping
if ($ping -ne $true){
write-host "waiting for $computer to be online" -ForegroundColor Red
Start-Sleep 10}
}

if ($bit -eq $true) {
Set-Service -name SharedAccess -ComputerName $computer -Status Stopped -StartupType Disabled
Set-Service -name MpsSvc -ComputerName $computer -Status Stopped -StartupType Disabled
}
}
}


# disable Windows Offline Files
If ($action -match "Offline") {
Foreach ($computer in $computers) {
$bit = $false 
while ( $bit -eq $false ){$ping = Test-Connection -Count 1 "$computer" -Quiet    
$bit = $ping
if ($ping -ne $true){
write-host "waiting for $computer to be online" -ForegroundColor Red
Set-Service -name SharedAccess -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Set-Service -name MpsSvc -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinueStart-Sleep 10}
}

if ($bit -eq $true) {
Set-Service -name CscService -ComputerName $computer -Status Stopped -StartupType Disabled
}
}
}


# delete Outlook temp files
If ($action -match "Outlook") {

Foreach ($computer in $computers) {
$bit = $false 
while ( $bit -eq $false ){$ping = Test-Connection -Count 1 "$computer" -Quiet    
$bit = $ping
if ($ping -ne $true){
write-host "waiting for $computer to be online" -ForegroundColor Red
Set-Service -name SharedAccess -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Set-Service -name MpsSvc -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Start-Sleep 10}
}

if ($bit -eq $true) {
$usersid = ([wmi]"win32_userAccount.Domain='$domain',Name='$user'").sid 
$usersid = $usersid.ToString()

$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::Users,$computer)
$products = ($reg.OpenSubKey("$usersid\Software\Microsoft\Office")).GetSubKeyNames()|ToArray

Foreach ($product in $products){
Try {
$OutlookTemp = If (($reg.OpenSubKey("$usersid\Software\Microsoft\Office\$product\Outlook\Security")).GetValue("OutlookSecureTempFolder") -eq $null) {$null} Else {($reg.OpenSubKey("$usersid\Software\Microsoft\Office\$product\Outlook\Security")).GetValue("OutlookSecureTempFolder").ToString()|ToArray}  
}
Catch {
# catch? there is no catch!
}
}

$OutlookTemp = $OutlookTemp -replace ':' , '$'

If ($OutlookTemp) {
write-host "Deleting \\$computer\$OutlookTemp" -ForegroundColor Green
Remove-Item -Path "Microsoft.PowerShell.Core\FileSystem::\\$computer\$OutlookTemp" -Recurse -Force -ErrorAction SilentlyContinue
Start-Sleep 5
}

clv userid -ErrorAction SilentlyContinue
clv reg -ErrorAction SilentlyContinue
clv products -ErrorAction SilentlyContinue
clv product -ErrorAction SilentlyContinue
clv OutlookTemp -ErrorAction SilentlyContinue
}
}
}


# reboot computer(s)
If ($action -match "Reboot computer") {
Foreach ($computer in $computers) {
$bit = $false 
while ( $bit -eq $false ){$ping = Test-Connection -Count 1 "$computer" -Quiet    
$bit = $ping
if ($ping -ne $true){
write-host "waiting for $computer to be online" -ForegroundColor Red
Set-Service -name SharedAccess -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Set-Service -name MpsSvc -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Start-Sleep 10}
}

if ($bit -eq $true) {
Restart-Computer $computer -Force}
}
}


# shutdown computer(s)
If ($action -match "Shutdown computer") {
Foreach ($computer in $computers) {
$bit = $false 
while ( $bit -eq $false ){$ping = Test-Connection -Count 1 "$computer" -Quiet    
$bit = $ping
if ($ping -ne $true){
write-host "waiting for $computer to be online" -ForegroundColor Red
Set-Service -name SharedAccess -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Set-Service -name MpsSvc -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Start-Sleep 10}
}

if ($bit -eq $true) {
Stop-Computer $computer -Force 
while ( $bit -eq $true ){
$ping = Test-Connection -Count 1 "$computer" -Quiet    
$bit = $ping
if ($ping -eq $false){
write-host "$computer is now powered off" -ForegroundColor Green 
}
}
}
}
}


# Dialogue to get script name(s)
If ($action -match "Run script") {

function Read-OpenFileDialog {    
param (        
[string]$WindowTitle="Please select Script(s)",        
[string]$InitialDirectory="$path2script",        
[string]$Filter = "Powershell script files (*.ps1)| *.ps1",        
[switch]$AllowMultiSelect=$true 
)     
Add-Type -AssemblyName System.Windows.Forms     
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog     
$openFileDialog.Title = $WindowTitle    
$openFileDialog.InitialDirectory = $InitialDirectory    
$openFileDialog.Filter = $Filter    
if ($AllowMultiSelect) {$openFileDialog.MultiSelect = $true}     
# if ($host.name -ne "ConsoleHost") {$openFileDialog.ShowHelp = $false}
# else 
$openFileDialog.ShowHelp = $true  
$openFileDialog.ShowDialog() | out-null    
if ($AllowMultiSelect) {return $openFileDialog.Filenames } else { return $openFileDialog.Filename }}

$scripts = Read-OpenFileDialog


# removes Payload path on remote computer, creates Payload path on remote computer 
Foreach ($computer in $computers) {
$bit = $false 
while ( $bit -eq $false ){$ping = Test-Connection -Count 1 "$computer" -Quiet    
$bit = $ping
if ($ping -ne $true){
write-host "waiting for $computer to be online" -ForegroundColor Red
Set-Service -name SharedAccess -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Set-Service -name MpsSvc -ComputerName $computer -Status Stopped -ErrorAction SilentlyContinue
Start-Sleep 10}
}

if ($bit -eq $true) {

Clear-Variable bit -Force -ErrorAction SilentlyContinue

Remove-Item -Path "Microsoft.PowerShell.Core\FileSystem::\\$computer\c$\temp\Payload" -Recurse -Force -ErrorAction SilentlyContinue

Foreach ($script in $scripts) {
New-Item -Path "Microsoft.PowerShell.Core\FileSystem::\\$computer\c$\temp\Payload" -type directory -Force
Copy-Item -Path $script -Destination \\$computer\c$\temp\Payload\ -Force


# Executes PSExec locally, remotely executes Powershell as the System Account
$scriptname = Split-Path "$script" -Leaf
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""$path2script\psexec.exe"" \\$computer -s cmd /c ""echo .|powershell.exe -ExecutionPolicy Bypass -file c:\temp\Payload\$scriptname""")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 2}}}
}
If ($script) {
echo "$action $script on $computer on $date by $tech" | Out-File -FilePath "$path2script\log.txt" -Append
write-host "check $path2script\log.txt for actions performed on computer(s)" -ForegroundColor Yellow
Start-Sleep 5
}
}


# creating log file and removing folder
Foreach ($computer in $computers) {
Try {
Remove-Item -Path "Microsoft.PowerShell.Core\FileSystem::\\$computer\c$\temp\Payload" -Recurse -Force
}
Catch {
write-host "no traces of Payload on $computer" -ForegroundColor Yellow
Write-Host " " -ForegroundColor Black
}
If ($action) {
If ($action -notmatch "Run script") {
echo "$action on $computer on $date by $tech" | Out-File -FilePath "$path2script\log.txt" -Append
write-host "check $path2script\log.txt for actions performed on computer(s)" -ForegroundColor Yellow
Start-Sleep 5
}
}
}


Clear-Variable comps -Force -ErrorAction SilentlyContinue
Clear-Variable NAC -Force -ErrorAction SilentlyContinue
Clear-Variable computer -Force -ErrorAction SilentlyContinue
Clear-Variable computers -Force -ErrorAction SilentlyContinue
Clear-Variable map -Force -ErrorAction SilentlyContinue
Clear-Variable mapdrives -Force -ErrorAction SilentlyContinue
Clear-Variable on -Force -ErrorAction SilentlyContinue
Clear-Variable off -Force -ErrorAction SilentlyContinue
Clear-Variable offline -Force -ErrorAction SilentlyContinue
Clear-Variable model -Force -ErrorAction SilentlyContinue
Clear-Variable action -Force -ErrorAction SilentlyContinue
Clear-Variable script -Force -ErrorAction SilentlyContinue
Clear-Variable scripts -Force -ErrorAction SilentlyContinue
Clear-Variable user -Force -ErrorAction SilentlyContinue
Clear-Variable username -Force -ErrorAction SilentlyContinue
Clear-Variable loggedin -Force -ErrorAction SilentlyContinue
Clear-Variable password -Force -ErrorAction SilentlyContinue
Clear-Variable newProc -Force -ErrorAction SilentlyContinue
Clear-Variable tech -Force -ErrorAction SilentlyContinue
Clear-Variable date -Force -ErrorAction SilentlyContinue
Clear-Variable psexec -Force -ErrorAction SilentlyContinue