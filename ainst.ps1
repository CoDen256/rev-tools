param (
    [switch]$find=$false,
    [switch]$old=$false,
    [string]$device = "-e"
)


if ($args.Count -eq 0)
{
    Write-Host "No apks specified"
}
elseif ($args.Count -eq 1  -and !$find)
{
    $apkfile=$args[0]
    $package=agetapk.ps1 $apkfile
    Write-Host "Running: adb $device uninstall $package"
    adb $device uninstall $package
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
    $package=agetapk.ps1 $apkfile
    Write-Host "Running: adb uninstall $package"
    adb uninstall $package

    Write-Host "Running: adb install-multiple $apks"
    adb install-multiple $apks
}
