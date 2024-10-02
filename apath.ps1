param (
[string]$search = ""
)

$package=aget.ps1 $search
$paths=adb shell "pm path $package | cut -d':' -f2"

Write-Host "Paths: "
Foreach ($p in $paths)
{
    Write-Host "$p"
}
Write-Host "`n"
@($package, $paths)