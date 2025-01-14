param (
    [switch]$dirty=$false,
    [switch]$verbose=$false
)
$apkfile=$args[0]
$name = Split-Path $apkfile -leaf
$name = ($name -split "\.out")[0]
$name = ($name -split "\.apk")[0]
$name = ($name -split "\.m")[0]
Write-Host "Building $name"

Write-Host "apktool.cmd b --use-aapt2 $PWD/$apkfile -o $PWD/$name.b.apk"
apktool.cmd b --use-aapt2 $PWD/"$apkfile" -o $PWD/"$name.b.apk" | Write-Host

Write-Host "zipalign.exe -v -p 4 $PWD/$name.b.apk $PWD/$name.z.apk"
$verboseStr = ""
if ($verbose){
    $verboseStr = "-v"
}
zipalign.exe $verboseStr -p 4 $PWD/"$name.b.apk" $PWD/"$name.z.apk" | Write-Host

Write-Host "Signing $name.b.apk"
$signed = asg.ps1 $PWD/"$name.z.apk"

mv $signed "$name.apk"
if (!$dirty){ # clean up if clean
    rm $PWD/"$name.b.apk"
    rm $PWD/"$name.z.apk"
}

Write-Host "Signed $name.apk"
Write-Output "$name.apk"