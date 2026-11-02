@echo off
REM FreeRDP Windows Build Script
REM Configures and builds FreeRDP with full Windows options including H264 support
REM Usage: run from a plain cmd.exe (not a VS shell)

setlocal EnableDelayedExpansion

set SOURCE_DIR=C:\Users\LudovicGasc\local-projects\FreeRDP
set BUILD_DIR=%SOURCE_DIR%\build\windows-msvc
set INSTALL_DIR=C:\FreeRDP
set VCPKG_ROOT=C:\vcpkg
set CMAKE_EXE=C:\Users\LudovicGasc\AppData\Local\Microsoft\WinGet\Packages\Kitware.CMake_Microsoft.Winget.Source_8wekyb3d8bbwe\cmake-4.4.4-windows-x86_64\bin\cmake.exe
set NINJA_EXE=C:\Users\LudovicGasc\AppData\Local\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe\ninja.exe
set VCVARS=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat
set LOG=%TEMP%\freerdp-build.log

echo === FreeRDP Windows Build === > %LOG%
echo Build dir: %BUILD_DIR% >> %LOG%
echo Install dir: %INSTALL_DIR% >> %LOG%
echo. >> %LOG%

REM Initialize Visual Studio environment
call "%VCVARS%"
if errorlevel 1 (
    echo ERROR: Failed to initialize VS environment >> %LOG%
    exit /b 1
)
echo VS environment initialized >> %LOG%

REM Add ninja and cmake to PATH
set PATH=%~dp0;%PATH%
for %%F in ("%NINJA_EXE%") do set PATH=%%~dpF;%PATH%
for %%F in ("%CMAKE_EXE%") do set PATH=%%~dpF;%PATH%

echo CMake: %CMAKE_EXE% >> %LOG%
echo Ninja: %NINJA_EXE% >> %LOG%

mkdir "%BUILD_DIR%" 2>nul

echo. >> %LOG%
echo === CMake Configure === >> %LOG%

"%CMAKE_EXE%" -G Ninja ^
    -S "%SOURCE_DIR%" ^
    -B "%BUILD_DIR%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" ^
    -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" ^
    -DVCPKG_TARGET_TRIPLET=x64-windows ^
    -DCMAKE_NINJA_FORCE_RESPONSE_FILE=ON ^
    -DWITH_OPENSSL=ON ^
    -DWITH_INTERNAL_MD4=ON ^
    -DWITH_INTERNAL_MD5=ON ^
    -DWITH_INTERNAL_RC4=ON ^
    -DWITH_MEDIA_FOUNDATION=ON ^
    -DWITH_FFMPEG=ON ^
    -DWITH_DSP_FFMPEG=ON ^
    -DWITH_VIDEO_FFMPEG=ON ^
    -DWITH_SWSCALE=ON ^
    -DWITH_OPENH264=ON ^
    -DWITH_JPEG=ON ^
    -DWINPR_UTILS_IMAGE_JPEG=ON ^
    -DWINPR_UTILS_IMAGE_PNG=ON ^
    -DWINPR_UTILS_IMAGE_WEBP=ON ^
    -DWITH_WEBP=ON ^
    -DWITH_OPUS=ON ^
    -DWITH_SOXR=ON ^
    -DWITH_LAME=ON ^
    -DWITH_FAAD2=ON ^
    -DWITH_DSP_EXPERIMENTAL=ON ^
    -DWITH_KRB5=OFF ^
    -DWITH_CAIRO=OFF ^
    -DWITH_PKCS11=OFF ^
    -DWITH_PCSC=OFF ^
    -DWITH_GSM=OFF ^
    -DWITH_FUSE=OFF ^
    -DWITH_ALSA=OFF ^
    -DWITH_PULSE=OFF ^
    -DWITH_OSS=OFF ^
    -DWITH_SYSTEMD=OFF ^
    -DWITH_CUPS=OFF ^
    -DWITH_WAYLAND=OFF ^
    -DWITH_X11=OFF ^
    -DWITH_UWAC=OFF ^
    -DWITH_RDTK=OFF ^
    -DCHANNEL_URBDRC=ON ^
    -DCHANNEL_RDPEWA=ON ^
    -DCHANNEL_RDPEAR=ON ^
    -DCHANNEL_RDP2TCP=ON ^
    -DCHANNEL_RDPECAM_CLIENT=ON ^
    -DCHANNEL_SSHAGENT=ON ^
    -DCHANNEL_PRINTER=ON ^
    -DCHANNEL_PRINTER_CLIENT=ON ^
    -DWITH_CLIENT_SDL=ON ^
    -DWITH_SDL_IMAGE_DIALOGS=ON ^
    -DWITH_CLIENT=ON ^
    -DWITH_CLIENT_COMMON=ON ^
    -DWITH_CLIENT_INTERFACE=ON ^
    -DWITH_SERVER=ON ^
    -DWITH_SAMPLE=ON ^
    -DWITH_WINPR_TOOLS_CLI=ON ^
    -DWITH_PROXY_APP=ON ^
    -DWITH_URIPARSER=ON ^
    -DWITH_SMARTCARD_EMULATE=ON ^
    -DWITH_WEBVIEW=ON ^
    -DWITH_WIN8=ON ^
    -DWITH_WINMM=ON ^
    -DWITH_BINARY_VERSIONING=ON ^
    -DWITH_RESOURCE_VERSIONING=ON ^
    -DWITH_FULL_CONFIG_PATH=ON ^
    -DWITHOUT_WINPR_3x_DEPRECATED=ON ^
    -DWITHOUT_FREERDP_3x_DEPRECATED=ON ^
    -DWITH_JSON_DISABLED=OFF ^
    >> %LOG% 2>&1

if errorlevel 1 (
    echo ERROR: CMake configure failed >> %LOG%
    type %LOG%
    exit /b 1
)

echo === CMake configure succeeded === >> %LOG%
echo. >> %LOG%
echo === Building === >> %LOG%

"%CMAKE_EXE%" --build "%BUILD_DIR%" --config Release --parallel >> %LOG% 2>&1

if errorlevel 1 (
    echo ERROR: Build failed >> %LOG%
    type %LOG%
    exit /b 1
)

echo === Build succeeded === >> %LOG%
echo. >> %LOG%
echo === Installing to %INSTALL_DIR% === >> %LOG%

"%CMAKE_EXE%" --install "%BUILD_DIR%" --prefix "%INSTALL_DIR%" >> %LOG% 2>&1

if errorlevel 1 (
    echo ERROR: Install failed >> %LOG%
    type %LOG%
    exit /b 1
)

echo === Installation complete === >> %LOG%
echo. >> %LOG%
echo FreeRDP installed to: %INSTALL_DIR% >> %LOG%

type %LOG%
