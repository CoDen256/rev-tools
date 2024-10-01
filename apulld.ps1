param (
    [switch]$f = $false
)
$search=$args[0]

$pulled=apull.ps1 $search -all
#$pulled=$pulled.spilt("`n`n")[-1]
Write-Host "Out $pulled"