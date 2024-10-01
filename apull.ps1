param (
    [string]$search = "",
    [switch]$all = $false,
    [switch]$v = $false,
    [switch]$dry = $false,
    [string]$name = ""
)
#Write-Host "$all $search $name"
$package=aget.ps1 $search

if ($name -eq ""){
    $name=$package.split(".")[-1]
}

Write-Host "$package"
Write-Host "$name`n"
$paths=adb shell "pm path $package | cut -d':' -f2"
#    Foreach ($p in $paths)
#    {
#        Write-Host "$p"
#    }
if ($all)
{
    Foreach ($p in $paths)
    {
        if($v){
            Write-Host "Pulling $p"
        }

        $n = $p.split("/")[-1]
        if ($n -eq "base.apk")
        {
            $n = "apk"
        }
        $n = "$name.$n"

        if ($dry)
        {
        }
        else
        {
            adb pull $p "./$n"
        }
        Write-Host "Pulled $n"
        $n
    }
    Write-Host "`n"
}
else
{
    $p=$paths[0]
    if($v){
        Write-Host "Pulling $p"
    }
    if ($dry)
    {

    }
    else
    {
        adb pull $p "./$name.apk"
    }
    Write-Host "Pulled $name.apk`n"
    $name.apk
}


