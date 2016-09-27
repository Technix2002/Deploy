# usage .\IE-Jscript.ps1


# populating variables
$target = 'c:\temp\Payload'
$system32 = 'c:\windows\system32'
$regsvr = "$system32\regsvr32.exe"
$dlls = 'vbscript.dll','jscript.dll'
$switches = '/s'


# execute command
Foreach ($dll in $dlls) {
$arglist = "$system32\$dll $switches"
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$regsvr $arglist")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}}


# cleans up installtion files 
Remove-Item "$target" -Recurse -Force