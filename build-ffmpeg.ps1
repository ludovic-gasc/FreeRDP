$log = "C:\Users\LudovicGasc\AppData\Local\Temp\ffmpeg-vcpkg.log"
"$(Get-Date) Starting FFmpeg install..." | Out-File $log
C:\vcpkg\vcpkg.exe install "ffmpeg[avcodec,avformat,swscale,swresample,x264,openh264,opus]:x64-windows" *>&1 | Tee-Object -FilePath $log -Append
"$(Get-Date) EXITCODE=$LASTEXITCODE" | Out-File $log -Append
