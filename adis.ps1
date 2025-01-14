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

        $i=$i.Substring(0,$i.Length-4)

        Write-Host "Dissasembling $PWD/$i.apk to $PWD/$i.out"
        Write-Output "$i.out"

        if ($f)
        {
            apktool.cmd -f d -o "$PWD/$i.out" "$PWD/$i.apk" | Write-Host
        }
        else
        {
            apktool.cmd d -o "$PWD/$i.out" "$PWD/$i.apk" | Write-Host
        }

    }
}
