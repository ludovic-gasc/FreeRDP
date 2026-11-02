# FreeRDP CMake Configure + Build + Install (PowerShell)
$ErrorActionPreference = "Continue"

$SOURCE   = "C:\Users\LudovicGasc\local-projects\FreeRDP"
$BUILD    = "$SOURCE\build\windows-msvc"
$INSTALL  = "C:\FreeRDP"
$VCPKG    = "C:\vcpkg"
$CMAKE    = "C:\Users\LudovicGasc\AppData\Local\Microsoft\WinGet\Packages\Kitware.CMake_Microsoft.Winget.Source_8wekyb3d8bbwe\cmake-4.4.4-windows-x86_64\bin\cmake.exe"
$NINJA    = "C:\Users\LudovicGasc\AppData\Local\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe\ninja.exe"
$VCVARS   = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
$LOG      = "$SOURCE\build\freerdp-build.log"

New-Item -ItemType Directory -Force -Path "$SOURCE\build" | Out-Null
New-Item -ItemType Directory -Force -Path $BUILD          | Out-Null

"$(Get-Date) === FreeRDP Configure ===" | Tee-Object -FilePath $LOG

# Gather VS environment variables via cmd /c vcvars64.bat && set
$vsEnvOutput = cmd.exe /c "`"$VCVARS`" && set" 2>&1
$vsEnvOutput | Where-Object { $_ -match "^[A-Za-z_][A-Za-z0-9_]*=" } | ForEach-Object {
    $parts = $_ -split "=", 2
    if ($parts.Count -eq 2) {
        [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1], "Process")
    }
}
"VS environment loaded" | Tee-Object -FilePath $LOG -Append

# Add ninja dir to PATH
$ninjaDir = Split-Path $NINJA
$env:PATH = "$ninjaDir;$env:PATH"

"cmake.exe: $CMAKE" | Tee-Object -FilePath $LOG -Append
"ninja.exe: $NINJA" | Tee-Object -FilePath $LOG -Append

$cmakeArgs = @(
    "-G", "Ninja",
    "-S", $SOURCE,
    "-B", $BUILD,
    "-DCMAKE_BUILD_TYPE=Release",
    "-DCMAKE_INSTALL_PREFIX=$INSTALL",
    "-DCMAKE_TOOLCHAIN_FILE=$VCPKG\scripts\buildsystems\vcpkg.cmake",
    "-DVCPKG_TARGET_TRIPLET=x64-windows",
    "-DWITH_OPENSSL=ON",
    "-DWITH_INTERNAL_MD4=ON",
    "-DWITH_INTERNAL_MD5=ON",
    "-DWITH_INTERNAL_RC4=ON",
    # H264 - all backends
    "-DWITH_MEDIA_FOUNDATION=ON",
    "-DWITH_FFMPEG=ON",
    "-DWITH_DSP_FFMPEG=ON",
    "-DWITH_VIDEO_FFMPEG=ON",
    "-DWITH_SWSCALE=ON",
    "-DWITH_OPENH264=ON",
    # Images
    "-DWITH_JPEG=ON",
    "-DWINPR_UTILS_IMAGE_JPEG=ON",
    "-DWINPR_UTILS_IMAGE_PNG=ON",
    "-DWINPR_UTILS_IMAGE_WEBP=ON",
    "-DWITH_WEBP=ON",
    # Audio (Opus disabled temporarily due to CMake target scope issue with vcpkg)
    "-DWITH_OPUS=OFF",
    "-DWITH_SOXR=ON",
    "-DWITH_LAME=ON",
    "-DWITH_FAAD2=ON",
    "-DWITH_DSP_EXPERIMENTAL=ON",
    # Security/Auth (Windows native)
    "-DWITH_KRB5=OFF",
    "-DWITH_PKCS11=OFF",
    "-DWITH_PCSC=OFF",
    # Disable Linux-only features
    "-DWITH_CAIRO=OFF",
    "-DWITH_GSM=OFF",
    "-DWITH_FUSE=OFF",
    "-DWITH_ALSA=OFF",
    "-DWITH_PULSE=OFF",
    "-DWITH_OSS=OFF",
    "-DWITH_SYSTEMD=OFF",
    "-DWITH_CUPS=OFF",
    "-DWITH_WAYLAND=OFF",
    "-DWITH_X11=OFF",
    "-DWITH_UWAC=OFF",
    "-DWITH_RDTK=OFF",
    # Channels
    "-DCHANNEL_URBDRC=ON",
    "-DCHANNEL_RDPEWA=ON",
    "-DCHANNEL_RDPEAR=ON",
    "-DCHANNEL_RDP2TCP=ON",
    "-DCHANNEL_RDPECAM_CLIENT=ON",
    "-DCHANNEL_SSHAGENT=OFF",
    "-DCHANNEL_PRINTER=ON",
    "-DCHANNEL_PRINTER_CLIENT=ON",
    # Clients and servers
    "-DWITH_CLIENT_SDL=ON",
    "-DWITH_SDL_IMAGE_DIALOGS=ON",
    "-DWITH_CLIENT=ON",
    "-DWITH_CLIENT_COMMON=ON",
    "-DWITH_CLIENT_INTERFACE=ON",
    "-DWITH_SERVER=ON",
    "-DWITH_SAMPLE=ON",
    "-DWITH_WINPR_TOOLS_CLI=ON",
    "-DWITH_PROXY_APP=ON",
    "-DWITH_SHADOW_SUBSYSTEM=OFF",
    "-DWITH_SERVER_SHADOW_CLI=OFF",
    "-DWITH_PLATFORM_SERVER=OFF",
    # Windows specifics
    "-DWITH_URIPARSER=ON",
    "-DWITH_SMARTCARD_EMULATE=ON",
    "-DWITH_WEBVIEW=ON",
    "-DWITH_WIN8=ON",
    "-DWITH_WINMM=ON",
    # Versioning
    "-DWITH_BINARY_VERSIONING=ON",
    "-DWITH_RESOURCE_VERSIONING=ON",
    "-DWITH_FULL_CONFIG_PATH=ON",
    "-DWITHOUT_WINPR_3x_DEPRECATED=ON",
    "-DWITHOUT_FREERDP_3x_DEPRECATED=ON",
    "-DWITH_JSON_DISABLED=OFF"
)

"Running cmake configure..." | Tee-Object -FilePath $LOG -Append
& $CMAKE @cmakeArgs *>&1 | Tee-Object -FilePath $LOG -Append
if ($LASTEXITCODE -ne 0) {
    "CONFIGURE FAILED (exit $LASTEXITCODE)" | Tee-Object -FilePath $LOG -Append
    exit $LASTEXITCODE
}
"$(Get-Date) Configure succeeded!" | Tee-Object -FilePath $LOG -Append
