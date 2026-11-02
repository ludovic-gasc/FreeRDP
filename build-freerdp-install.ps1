# FreeRDP Install Script (PowerShell)
$SOURCE   = "C:\Users\LudovicGasc\local-projects\FreeRDP"
$BUILD    = "$SOURCE\build\windows-msvc"
$INSTALL  = "C:\FreeRDP"
$CMAKE    = "C:\Users\LudovicGasc\AppData\Local\Microsoft\WinGet\Packages\Kitware.CMake_Microsoft.Winget.Source_8wekyb3d8bbwe\cmake-4.4.4-windows-x86_64\bin\cmake.exe"
$LOG      = "$SOURCE\build\freerdp-install.log"
$VCVARS   = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
$VCPKG    = "C:\vcpkg\installed\x64-windows"

# Load VS env
$vsEnvOutput = cmd.exe /c "`"$VCVARS`" && set" 2>&1
$vsEnvOutput | Where-Object { $_ -match "^[A-Za-z_][A-Za-z0-9_]*=" } | ForEach-Object {
    $parts = $_ -split "=", 2
    if ($parts.Count -eq 2) { [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1], "Process") }
}

"$(Get-Date) === Installing FreeRDP to $INSTALL ===" | Tee-Object -FilePath $LOG

& $CMAKE --install $BUILD --prefix $INSTALL *>&1 | Tee-Object -FilePath $LOG -Append
$installExit = $LASTEXITCODE
"$(Get-Date) Install exit: $installExit" | Tee-Object -FilePath $LOG -Append

if ($installExit -eq 0) {
    # Copy vcpkg DLLs to install bin directory
    "Copying runtime DLLs from vcpkg..." | Tee-Object -FilePath $LOG -Append
    $dllsToCopy = @(
        "$VCPKG\bin\avcodec-*.dll",
        "$VCPKG\bin\avformat-*.dll",
        "$VCPKG\bin\avutil-*.dll",
        "$VCPKG\bin\swscale-*.dll",
        "$VCPKG\bin\swresample-*.dll",
        "$VCPKG\bin\openssl-*",
        "$VCPKG\bin\libssl-*.dll",
        "$VCPKG\bin\libcrypto-*.dll",
        "$VCPKG\bin\openh264.dll",
        "$VCPKG\bin\x264-*.dll",
        "$VCPKG\bin\opus.dll",
        "$VCPKG\bin\SDL3.dll",
        "$VCPKG\bin\SDL2.dll",
        "$VCPKG\bin\SDL2_image.dll",
        "$VCPKG\bin\SDL3_image.dll",
        "$VCPKG\bin\SDL3_ttf.dll",
        "$VCPKG\bin\zlib1.dll",
        "$VCPKG\bin\cjson.dll",
        "$VCPKG\bin\libwebp.dll",
        "$VCPKG\bin\libjpeg-turbo.dll",
        "$VCPKG\bin\jpeg62.dll",
        "$VCPKG\bin\turbojpeg.dll",
        "$VCPKG\bin\libpng16.dll",
        "$VCPKG\bin\soxr.dll",
        "$VCPKG\bin\libusb-1.0.dll",
        "$VCPKG\bin\uriparser.dll",
        "$VCPKG\bin\cbor.dll",
        "$VCPKG\bin\fido2.dll"
    )
    
    New-Item -ItemType Directory -Force -Path "$INSTALL\bin" | Out-Null
    foreach ($pattern in $dllsToCopy) {
        $files = Get-Item $pattern -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            Copy-Item $f.FullName "$INSTALL\bin\" -Force
            "  Copied: $($f.Name)" | Tee-Object -FilePath $LOG -Append
        }
    }
    
    "=== Installation complete ===" | Tee-Object -FilePath $LOG -Append
    "FreeRDP binaries: $INSTALL\bin" | Tee-Object -FilePath $LOG -Append
    Get-ChildItem "$INSTALL\bin\*.exe" | ForEach-Object {
        "  $($_.Name)" | Tee-Object -FilePath $LOG -Append
    }
}
exit $installExit
