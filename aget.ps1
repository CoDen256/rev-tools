param (
    [string]$search = ""
)

if ($search -eq ""){
    Write-Host "search not specified"
    exit
}
$package=adb shell "pm list packages | grep $search | cut -d':' -f2"
$package=$package -Split "`r`n"

if ($package.count -eq 0 )
{
    Write-Host "list packages grep '$search' gave nothing "
    exit
}
if ($package.count -gt 1 )
{
    Write-Host "grep '$search' gave multiple packages:"

    Foreach ($i in $package)
    {
        Write-Host "$i"
    }
    exit
}
$package[0]