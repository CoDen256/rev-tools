param (
    [string]$package = "",
    [string]$apk = ""
)

$signature = ""

if ($package -ne ""){
    $package=aget.ps1 $package
    Write-Host "Getting signature for $package"
    $signature=(adb shell "dumpsys package $package | grep Signatures | sed 's/.*\[//;s/\].*//'" | Out-String).Trim()
}
else
{
    Write-Host "Getting signature for $apk"
    $apksignerOutput=(apksigner verify --print-certs $apk)
    Write-Host ($apksignerOutput -join "`r`n")
    $sha256=(echo $apksignerOutput| Select-String -Pattern "SHA-256 digest:\s*([a-f0-9]+)").Matches.Groups[1]
    Write-Host "Found: $sha256"

    $formattedSha256=($sha256 -split "(?<=\G..)" -join ":").ToUpper()
    $formattedSha256=$formattedSha256.Substring(0, $formattedSha256.Length-1)

    $signature=$formattedSha256
}

Write-Host "Found signature: $signature"
$signature