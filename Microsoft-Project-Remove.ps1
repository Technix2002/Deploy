# Usage .\Microsoft-Project-Remove.ps1


# Checks architecture to set variables
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($query.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'}

If($query.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'}


# populating variables
$target = 'c:\temp\Payload'
$processes = 'wusa','msiexec','excel','groove','msaccess','mspub','onenote','outlook','powerpoint','winword','winproj'
$appremove = 'Microsoft Office Project'


# ends task on applications
Foreach ($process in $processes) {
Stop-Process -processname $process -Force -ErrorAction SilentlyContinue
}


# uninstalls previous versions
If ($appremove) {
Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%$appremove%'" | Foreach-Object { 
Write-Host "Uninstalling: $($_.Name)"
$rv = $_.Uninstall().ReturnValue 
if($rv -eq 0) {"$($_.Name) uninstalled successfully"}
}
}


# cleans up installtion files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue