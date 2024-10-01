$apkfile=$args[0]
$name = Split-Path $apkfile -leaf

apktool.cmd b "$apkfile" -o "$name.b.apk"
zipalign.exe -v -p 4 "$name.b.apk" "$name.z.apk"
apksigner.bat sign -ks C:\Users\denbl\.android\release.keystore --out "$name.r.apk" "$name.z.apk"