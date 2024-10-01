$apkfile=$args[0]
if ($apkfile -eq $null)
{
    Write-Host "No args"
}
else
{
    apktool.cmd b "$apkfile"
}

