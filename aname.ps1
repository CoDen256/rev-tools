$apkfile=$args[0]

$package=aapt dump badging $apkfile | findstr -n /C:"package: name"
$package=$package.split("'")[1]

$package