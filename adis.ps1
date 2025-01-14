param (
    [switch]$f = $false
)
$first=$args[0]
if ($first -eq $null)
{
    Write-Host "No args"
}

else
{
    Foreach ($i in $args)

    {


        if ($i -notmatch '.apk$')
        {
            $i += ".apk"
        }

        Write-Host "Dissasembling $PWD/$i to $PWD/$i.out"

        if ($f)
        {
            apktool.cmd -f d -o "$PWD/$i.out" "$PWD/$i"
        }
        else
        {
            apktool.cmd d -o "$PWD/$i.out" "$PWD/$i"
        }
        Write-Output "$PWD/$i.out"
    }
}
