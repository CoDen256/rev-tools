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
            apktool.cmd -f d "$i"

        }
        else
        {
            apktool.cmd d "$i"
        }

    }
}
