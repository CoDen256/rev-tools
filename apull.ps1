param (
    [string]$search = "",
    [switch]$all = $false,
    [switch]$v = $false,
    [string]$name = ""
)
#Write-Host "$all $search $name"
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
}
else
{
    $package=$package[0]
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
            $n = "$name.$n"
#            adb pull $p "./$n"
            Write-Host "Pulled $n"
#            Out-Host "$n"
        }
    }
    else
    {
        $p=$paths[0]
        if($v){
            Write-Host "Pulling $p"
        }
#        adb pull $p "./$name.apk"
        Write-Host "Pulled $name.apk"
#        Out-Host "$name.apk"
    }
}

