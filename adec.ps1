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
        $name = (Get-Item $i).Basename
        $name += "-decompiled"
        Write-Host "Decompiling to $name"
        jadx.cmd -d $name $i
    }
}
