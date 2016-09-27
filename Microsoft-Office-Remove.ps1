# Usage .\OfficeRemove.ps1


# Checks architecture to set variables
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($query.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'}

If($query.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'}


# populating variables
$target = 'c:\temp\Payload'
$processes = 'wusa','msiexec','excel','groove','msaccess','mspub','onenote','outlook','powerpoint','winword'
$appremove = 'Microsoft Office'
$locations = 'c:\Users\Public\Desktop','C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office'  


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


# removes extra files 
if($rv -eq 0) {
$desktop = $locations.GetValue(0)
$startprog = $locations.GetValue(1)
Remove-Item "$desktop\Microsoft Office*" -Force -ErrorAction SilentlyContinue
Remove-Item "$starprog\" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\$ProgFiles\Microsoft Office\" -Recurse -Force -ErrorAction SilentlyContinue}


# cleans up installtion files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue