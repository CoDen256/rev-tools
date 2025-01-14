param (
    [switch]$clean=$false
)
$first=$args[0]
if ($first -eq $null)
{
    Write-Host "No args"
}
if ($clean)
{
    rm *.*.apk
    rm *.git
    rm tmp*
}

Write-Host "Getting $first"
$base=(apull.ps1 $first -name $first)
Write-Host "Pulled $base; Disassembling"
$dis=(adis.ps1 $base)
ainit.ps1 $dis
Write-Host "Dissasembled to $dis; Rebuilding"
$build=(abl.ps1 -verbose $dis)
Write-Host "Rebuilt $build; Installing"
ainst.ps1 $build