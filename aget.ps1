param (
    [string]$search = ""
)
$ErrorActionPreference = "Stop"

if ($search -eq ""){
    Write-Host "search not specified"
    return
}
$package=adb shell "pm list packages --user 0 | grep -i $search | cut -d':' -f2"
$package=$package -Split "`r`n"

if ($package.count -eq 0 )
{
    Write-Host "list packages grep '$search' gave nothing "
    return
}
if ($package.count -gt 1 )
{
    Write-Host "grep '$search' gave multiple packages:"

    Foreach ($i in $package)
    {
        Write-Host "$i"
    }
    return
}
$package=$package[0]
Write-Host "Found: $package"
$package