param (
    [switch]$find=$false,
    [switch]$old=$false,
    [switch]$d=$false
)

$device="-e"
if ($d){
    $device="-d"
}

if ($args.Count -eq 0)
{
    Write-Host "No apks specified"
}
elseif ($args.Count -eq 1  -and !$find)
{
    $apkfile=$args[0]
    $package=aname.ps1 $apkfile
    $apkSig=(asginfo.ps1 -apk $apkfile 6>$null ).toString().trim()
    $targetSig=(asginfo.ps1 -package $package 6>$null ).trim()

    Write-Host "`nCurrent Signature: $apkSig`nTarget Signature: $targetSig`n"
    if ($apkSig -ne $targetSig){
        Write-Host "Running: adb $device uninstall $package"
        adb $device uninstall $package
    }

    Write-Host "Running: adb $device install $apkfile"
    adb $device install $apkfile

}
else
{
    $apks=$args
    if ($find){
        $tofind=$args[0]

        if (!$old){

            $apks=Get-ChildItem -path . -filter *.apk -file -ErrorAction silentlycontinue -recurse | Where-object {$_ -match $tofind } | Where-object {$_ -match '\.s\.apk$'}
        }else {
            $apks=Get-ChildItem -path . -filter *.apk -file -ErrorAction silentlycontinue -recurse | Where-object {$_ -match $tofind } | Where-object {$_ -notmatch '\.s\.apk$|\.z\.apk$|\.b\.apk$'}
        }

    }

    $apkfile=$apks[0]
    $package=aname.ps1 $apkfile
    Write-Host "Running: adb uninstall $package"
    adb uninstall $package

    Write-Host "Running: adb install-multiple $apks"
    adb install-multiple $apks
}
