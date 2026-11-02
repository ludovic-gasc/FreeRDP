# FreeRDP Build Script (PowerShell)
$SOURCE   = "C:\Users\LudovicGasc\local-projects\FreeRDP"
$BUILD    = "$SOURCE\build\windows-msvc"
$CMAKE    = "C:\Users\LudovicGasc\AppData\Local\Microsoft\WinGet\Packages\Kitware.CMake_Microsoft.Winget.Source_8wekyb3d8bbwe\cmake-4.4.4-windows-x86_64\bin\cmake.exe"
$LOG      = "$SOURCE\build\freerdp-build.log"
$VCVARS   = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
$NINJA    = "C:\Users\LudovicGasc\AppData\Local\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe\ninja.exe"

# Load VS env
$vsEnvOutput = cmd.exe /c "`"$VCVARS`" && set" 2>&1
$vsEnvOutput | Where-Object { $_ -match "^[A-Za-z_][A-Za-z0-9_]*=" } | ForEach-Object {
    $parts = $_ -split "=", 2
    if ($parts.Count -eq 2) { [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1], "Process") }
}
$ninjaDir = Split-Path $NINJA
$env:PATH = "$ninjaDir;$env:PATH"

"$(Get-Date) === Building FreeRDP ===" | Tee-Object -FilePath $LOG -Append

$cores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
"Building with $cores parallel jobs" | Tee-Object -FilePath $LOG -Append

& $CMAKE --build $BUILD --config Release --parallel $cores *>&1 | Tee-Object -FilePath $LOG -Append
$buildExit = $LASTEXITCODE
"$(Get-Date) Build exit: $buildExit" | Tee-Object -FilePath $LOG -Append
exit $buildExit
