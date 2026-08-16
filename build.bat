@echo off
setlocal
rem ============================================================
rem  Ollama-Vulkan build script
rem
rem  Builds Ollama with the Vulkan GPU backend. The finished
rem  package is assembled into ..\Ollama-Vulkan\ and can be zipped
rem  as Ollama-Vulkan.zip.
rem
rem  Usage:
rem    build.bat configure   - configure the superbuild
rem    build.bat build       - build everything (default)
rem    build.bat package     - build + assemble the release folder
rem
rem  Prerequisites:
rem    - Visual Studio 2022 Build Tools (VC v143)
rem    - Vulkan SDK (VULKAN_SDK env var, or the default install path)
rem    - cmake / ninja / git / go on PATH, or in ..\..\work\tools
rem ============================================================

set "SRC=%~dp0"
if "%SRC:~-1%"=="\" set "SRC=%SRC:~0,-1%"
for %%I in ("%SRC%\..") do set "PROJECT=%%~fI"
set "OUT=%PROJECT%\Ollama-Vulkan"
set "BUILD=%SRC%\build"

rem ---- toolchain discovery (shared tools from the workspace layout) ----
if exist "%SRC%\..\..\work\tools" set "TOOLSPATH=%SRC%\..\..\work\tools"
if defined TOOLSPATH set "PATH=%TOOLSPATH%\cmake-4.4.2-windows-x86_64\bin;%TOOLSPATH%;%TOOLSPATH%\go\bin;%TOOLSPATH%\cmd;%PATH%"

rem ---- Visual Studio environment ----
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
  call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul
) else (
  echo Error: Visual Studio 2022 Build Tools not found at the default path.
  echo Set up vcvars64.bat manually, or edit this script.
  exit /b 1
)

rem ---- Vulkan SDK ----
if "%VULKAN_SDK%"=="" set "VULKAN_SDK=C:\VulkanSDK\1.4.309.0"
if not exist "%VULKAN_SDK%" (
  echo Error: Vulkan SDK not found at %VULKAN_SDK%
  echo Install it or set VULKAN_SDK to the correct path.
  exit /b 1
)

rem ---- Go proxy settings (China-friendly) ----
set "GOPROXY=https://goproxy.cn,direct"
set "GOSUMDB=off"
set "GIT_SSL_NO_VERIFY=true"

where cmake >nul 2>nul || (echo Error: cmake not found. Install it or add it to PATH. & exit /b 1)
where go >nul 2>nul || (echo Error: go not found. Install it or add it to PATH. & exit /b 1)
where git >nul 2>nul || (echo Error: git not found. Install it or add it to PATH. & exit /b 1)

if /I "%~1"=="configure" goto configure
if /I "%~1"=="package" goto package
goto build

:configure
cmake -S "%SRC%" -B "%BUILD%" -DOLLAMA_LLAMA_BACKENDS=vulkan -DOLLAMA_VERSION=v0.32.6 -DCMAKE_BUILD_TYPE=Release -G "Visual Studio 17 2022" -A x64
if errorlevel 1 (
  echo configure failed
  exit /b 1
)
echo Configure OK. Run: build.bat build
exit /b 0

:build
if not exist "%BUILD%\CMakeCache.txt" (
  call :configure
  if errorlevel 1 exit /b 1
)
cmake --build "%BUILD%" --config Release --parallel 8
if errorlevel 1 (
  echo build failed
  exit /b 1
)
exit /b 0

:package
call :build
if errorlevel 1 exit /b 1

if exist "%OUT%" rmdir /s /q "%OUT%"
mkdir "%OUT%"

copy /y "%SRC%\ollama.exe" "%OUT%\" >nul
if not exist "%BUILD%\lib\ollama" (
  echo Error: native payload missing under %BUILD%\lib\ollama
  exit /b 1
)
xcopy /e /i /y "%BUILD%\lib\ollama" "%OUT%\lib\ollama\" >nul

rem ---- MinGW runtime helper (kept for layout parity with the release zip) ----
if exist "C:\Users\Han\mingw64\bin\libwinpthread-1.dll" copy /y "C:\Users\Han\mingw64\bin\libwinpthread-1.dll" "%OUT%\" >nul

copy /y "%SRC%\start-ollama.bat" "%OUT%\" >nul

echo.
echo Package ready: %OUT%
echo Zip it with:  tar -a -c -f "%PROJECT%\Ollama-Vulkan.zip" -C "%PROJECT%" Ollama-Vulkan
exit /b 0
