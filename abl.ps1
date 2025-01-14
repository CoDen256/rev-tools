param (
    [switch]$verbose=$false
)
$apkfile=$args[0]
$name = Split-Path $apkfile -leaf
$name = ($name -split "\.out")[0]
$name = ($name -split "\.apk")[0]
$name = ($name -split "\.merged")[0]
Write-Host "Building $name"

Write-Host "apktool.cmd b --use-aapt2 $PWD/$apkfile -o $PWD/$name.b.apk"
apktool.cmd b --use-aapt2 $PWD/"$apkfile" -o $PWD/"$name.b.apk"

Write-Host "zipalign.exe -v -p 4 $PWD/$name.b.apk $PWD/$name.z.apk"
zipalign.exe -v -p 4 $PWD/"$name.b.apk" $PWD/"$name.z.apk"

Write-Host "Signing $name.b.apk"
$signed = asg.ps1 $PWD/"$name.z.apk"

if (!$verbose){
    rm $PWD/"$name.b.apk"
    rm $PWD/"$name.z.apk"
    mv $signed "$name.apk"

    Write-Output $name.apk
}
else
{
    Write-Output $signed
}