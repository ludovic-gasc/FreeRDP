# FreeRDP Windows Dependencies Installer
# Requires: vcpkg at C:\vcpkg, Visual Studio Build Tools 2022
param(
    [string]$Triplet = "x64-windows"
)

$VCPKG = "C:\vcpkg\vcpkg.exe"
$LOG = "C:\freerdp-deps-install.log"

function Log { param([string]$msg) $ts = Get-Date -Format "HH:mm:ss"; "$ts $msg" | Tee-Object -FilePath $LOG -Append }

Log "=== FreeRDP Windows Dependency Installer ==="
Log "Triplet: $Triplet"

# Packages needed for FreeRDP full Windows build with H264 support
$packages = @(
    # Core
    "openssl:$Triplet",
    "zlib:$Triplet",
    # JSON (Azure AAD auth)
    "cjson:$Triplet",
    # H264 via FFmpeg (includes libx264, libvpx, etc.)
    "ffmpeg[avcodec,avformat,avutil,swscale,swresample,x264,openh264,opus]:$Triplet",
    # H264 via OpenH264 (Cisco)
    "openh264:$Triplet",
    # Graphics scaling
    "cairo:$Triplet",
    # Audio
    "opus:$Triplet",
    "libvorbis:$Triplet",
    "libsoxr:$Triplet",
    # Image formats
    "libjpeg-turbo:$Triplet",
    "libwebp:$Triplet",
    "libpng:$Triplet",
    # USB redirection
    "libusb:$Triplet",
    # SDL2 client
    "sdl2:$Triplet",
    "sdl2-image:$Triplet",
    # URI parser
    "uriparser:$Triplet",
    # CBOR for WebAuthn
    "libcbor:$Triplet",
    # FIDO2 for WebAuthn
    "libfido2:$Triplet"
)

$total = $packages.Count
$i = 0
foreach ($pkg in $packages) {
    $i++
    Log "[$i/$total] Installing $pkg ..."
    $result = & $VCPKG install $pkg 2>&1
    if ($LASTEXITCODE -ne 0) {
        Log "ERROR installing $pkg : $result"
    } else {
        $last = ($result | Select-Object -Last 3) -join " | "
        Log "  OK: $last"
    }
}

Log "=== All packages installed ==="

# Show installed packages summary
Log "--- Installed packages list ---"
& $VCPKG list 2>&1 | ForEach-Object { Log "  $_" }
