# usage .\Bin2S.ps1 -Path c:\whatever.exe , this copies output to clip board to paste in a new script 


param (
         [string] $Path = $(throw "-Path is required")) 

function Convert-BinaryToString {
     [CmdletBinding()]
     param (
         [string] $FilePath = $(throw "-FilePath is required") 
     )
 
    try {
         $ByteArray = [System.IO.File]::ReadAllBytes($FilePath);
     }
     catch {
         throw "Failed to read file. Please ensure that you have permission to the file, and that the file path is correct.";
     }
 
    if ($ByteArray) {
         $Base64String = [System.Convert]::ToBase64String($ByteArray);
     }
     else {
         throw '$ByteArray is $null.';
     }
 
    Write-Output -InputObject $Base64String;
 }
 
$Output = Convert-BinaryToString -FilePath $Path ;
echo $Output | Out-File c:\temp\Bin2S.txt