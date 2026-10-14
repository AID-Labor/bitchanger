@echo off
setlocal EnableDelayedExpansion

rem Dieses Skript erstellt mit Hilfe des jpackage Tools aus einer ausfuehrbaren JAR Datei
rem einen nativen Installer fuer Windows. Alle von dem Java Programm benoetigten Komponenten (JRE, JavaFX, ...)
rem werden dabei mit in den Installer eingebunden, sodass das Programm nach der Installation auf jedem Windows Betriebssystem
rem unabhaengig von anderen Programmen oder Installationen lauffaehig ist.

rem Es werden zwei Installer in den gaengigen Formaten bereitgestellt (.exe und .msi)

rem ---- Praefluege -----------------------------------------------------------------------------------------------------

where jpackage >nul 2>&1 || (
    echo Fehler: jpackage nicht gefunden. Bitte mit JDK 25+ verwenden.
    exit /b 1
)

rem ---- Benoetigte Informationen in Variablen speichern ----------------------------------------------------------------

if not defined NAME set "NAME=Bitchanger"
if not defined DESCRIPTION set "DESCRIPTION=Rechner fuer beliebige Zahlensysteme"
if not defined VERSION set "VERSION=1.1.0"
if not defined VENDOR set "VENDOR=Entwicklungsprojekt_EB2020 by Tim Muehle und Moritz Wolter"
rem set COPYRIGHT=...

set "MAIN_JAR=bitchanger-%VERSION%.jar"
if not defined INPUT set "INPUT=installer\source\Windows"
if not defined OUT set "OUT=installer\%VERSION%\Windows"
set "LICENSE_FILE=%INPUT%\jpackage\LICENSE.txt"

if not exist "%LICENSE_FILE%" copy "LICENSE.txt" "%LICENSE_FILE%" >nul


rem ---- Installer erzeugen ---------------------------------------------------------------------------------------------

echo.
echo Installer fuer Windows werden erzeugt.
echo.

if not exist "%OUT%" mkdir "%OUT%"


rem ---- exe ----
echo %NAME%-%VERSION%-win-install.exe wird erstellt
echo.

jpackage ^
--type exe ^
--name %NAME% ^
--description %DESCRIPTION% ^
--vendor %VENDOR% ^
--app-version %VERSION% ^
--input %INPUT%\jpackage ^
--dest %OUT% ^
--main-jar %MAIN_JAR% ^
--java-options --enable-native-access=javafx.graphics ^
--icon .\Logo\%NAME%.ico ^
--license-file %LICENSE_FILE% ^
--win-dir-chooser ^
--win-shortcut ^
--win-menu ^
--win-menu-group ^
Bitchanger

if errorlevel 1 (
    echo Fehler: jpackage fuer .exe fehlgeschlagen.
    exit /b 1
)

if exist "%OUT%\%NAME%-%VERSION%.exe" (
    ren "%OUT%\%NAME%-%VERSION%.exe" "%NAME%-%VERSION%-win-install.exe"
) else (
    echo Fehler: %OUT%\%NAME%-%VERSION%.exe wurde nicht erzeugt.
    exit /b 1
)

echo.
echo.


rem ---- msi ----
echo %NAME%-%VERSION%-win-install.msi wird erstellt
echo.

jpackage ^
--type msi ^
--name %NAME% ^
--description %DESCRIPTION% ^
--vendor %VENDOR% ^
--app-version %VERSION% ^
--input %INPUT%\jpackage ^
--dest %OUT% ^
--main-jar %MAIN_JAR% ^
--java-options --enable-native-access=javafx.graphics ^
--icon .\Logo\%NAME%.ico ^
--license-file %LICENSE_FILE% ^
--win-dir-chooser ^
--win-shortcut ^
--win-menu ^
--win-menu-group ^
Bitchanger

if errorlevel 1 (
    echo Fehler: jpackage fuer .msi fehlgeschlagen.
    exit /b 1
)

if exist "%OUT%\%NAME%-%VERSION%.msi" (
    ren "%OUT%\%NAME%-%VERSION%.msi" "%NAME%-%VERSION%-win-install.msi"
) else (
    echo Fehler: %OUT%\%NAME%-%VERSION%.msi wurde nicht erzeugt.
    exit /b 1
)

echo.
echo.
echo Fertig.

rem ---- Auf Bestaetigung von Benutzer warten ----------------------------------------------------------------------------
echo Zum Abschliessen eine beliebige Taste druecken
pause >nul
