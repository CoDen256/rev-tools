$apkfile=$args[0]
$name = Split-Path $apkfile -leaf

apktool.cmd b "$apkfile" -o "$name.b.apk"
zipalign.exe -v -p 4 "$name.b.apk" "$name.z.apk"
$signed = asg.ps1 "$name.z.apk"
@("$name.b.apk", "$name.z.apk", $signed)