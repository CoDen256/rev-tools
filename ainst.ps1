param (
    [switch]$find=$false,
    [switch]$old=$false
)

if ($args.Count -eq 0)
{
    Write-Host "No apks specified"
}
elseif ($args.Count -eq 1  -and !$find)
{
    $apkfile=$args[0]
    Write-Host "Running: adb install -r $apkfile"
    adb install -r $apkfile

}
else
{
    $apks=$args
    if ($find){
        $tofind=$args[0]

        if (!$old){

            $apks=Get-ChildItem -path . -filter *.apk -file -ErrorAction silentlycontinue -recurse | Where-object {$_ -match $tofind } | Where-object {$_ -match '.r.apk$'}
        }else {
            $apks=Get-ChildItem -path . -filter *.apk -file -ErrorAction silentlycontinue -recurse | Where-object {$_ -match $tofind } | Where-object {$_ -notmatch '.r.apk$|.z.apk$|.b.apk$'}
        }

    }
    Write-Host "Running: adb -r install-multiple $apks"
    adb install-multiple -r $apks
}
