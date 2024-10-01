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

        if ($f)
        {
            apktool.cmd -f d "$i.apk"

        }
        else
        {
            apktool.cmd d "$i.apk"
        }

    }
}
