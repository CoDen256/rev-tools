param (
[string]$search = "",
[switch]$all = $false,
[switch]$v = $false,
[switch]$dry = $false,
[string]$name = ""
)

$r=apath.ps1 $search
$package=$r[0]
$paths=$r[1]

if ($name -eq ""){
    $name=$package.split(".")[-1]
}

if ($all)
{
    Foreach ($p in $paths)
    {
        if($v){Write-Host "Pulling $p" }

        $n = $p.split("/")[-1]
        if ($n -eq "base.apk")
        {
            $n = "apk"
        }
        $n = "$name.$n"

        if (!$dry)
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
    if($v){Write-Host "Pulling $p" }
    if (!$dry)
    {
        adb pull $p "./$name.apk"
    }
    Write-Host "Pulled $name.apk`n"
    $name.apk
}


