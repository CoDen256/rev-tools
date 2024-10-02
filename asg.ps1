$name=$args[0]
if ($name -eq "" -or $name -eq $null)
{
    Write-Host "No args"
    exit 1
}

if ($name -notmatch '\.apk$')
{
    $name += ".z.apk"
}
$outname=$name
#Write-Host "z $outname"
# remove suffixes
if ($outname -match '\.r\.apk$')
{
    $outname = ($outname -split ".r.apk")[0]
}
#Write-Host "r $outname"
if ($outname -match '\.b\.apk$')
{
    $outname = ($outname -split ".b.apk")[0]
}
#Write-Host "b $outname"
if ($outname -match '\.z\.apk$')
{
    $outname = ($outname -split ".z.apk")[0]
}
#Write-Host "z $outname"
if ($outname -match '\.apk$')
{
    $outname = ($outname -split "\.apk")[0]
}
#Write-Host "plain $outname"

$outname+=".s.apk"
#Write-Host "final $outname"
Write-Host "Running: apksigner.bat sign -ks C:\Users\denbl\.android\release.keystore --out $outname $name"
#apksigner.bat sign -ks C:\Users\denbl\.android\release.keystore --out "$outname" "$name"

$outname