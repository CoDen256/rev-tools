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

        if ($f)
        {
            apktool.cmd -f d -o $PWD/$i.out $PWD/"$i"

        }
        else
        {
            apktool.cmd d -o $PWD/$i.out $PWD/"$i"
        }

    }
}
