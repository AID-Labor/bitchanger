@echo off
setlocal EnableDelayedExpansion

rem Dieses Skript erstellt mit Hilfe von Maven eine ausfuehrbare JAR-Datei aus dem Java-Projekt,
rem kopiert diese in das Verzeichnis "installer\source\Windows" und erzeugt dann mit einem weiteren
rem Skript plattformspezifische Installer fuer Windows (.exe und .msi).

rem ---- Praefluege -----------------------------------------------------------------------------------------------------

where mvn >nul 2>&1 || (
    echo Fehler: Maven ^(mvn^) nicht gefunden.
    exit /b 1
)

where jpackage >nul 2>&1 || (
    echo Fehler: jpackage nicht gefunden. Bitte mit JDK 25+ verwenden.
    exit /b 1
)

if not exist "Logo\Bitchanger.ico" (
    echo Fehler: Logo\Bitchanger.ico nicht gefunden.
    exit /b 1
)

if not exist "LICENSE.txt" (
    echo Fehler: LICENSE.txt nicht gefunden.
    exit /b 1
)

rem ---- Benoetigte Informationen in Variablen speichern ----------------------------------------------------------------

set "NAME=Bitchanger"
set "DESCRIPTION=Rechner fuer beliebige Zahlensysteme"
set "VERSION=1.1.0"
set "VENDOR=Entwicklungsprojekt_EB2020 by Tim Muehle und Moritz Wolter"
set "COPYRIGHT=Copyright 2020 (c) Tim Muehle & Moritz Wolter"

set "INPUT=installer\source\Windows"
set "OUT=installer\%VERSION%\Windows"


rem ---- Maven build -----------------------------------------------------------------------------------------------------
echo.
echo Maven Build durchfuehren
echo.
call mvn clean install
if errorlevel 1 (
    echo Fehler: Maven Build fehlgeschlagen.
    exit /b 1
)


rem ---- JARs sichern ----------------------------------------------------------------------------------------------------
echo.
echo JAR-Dateien kopieren

if not exist "%OUT%" mkdir "%OUT%"
if not exist "%INPUT%\%VERSION%" mkdir "%INPUT%\%VERSION%"
if exist "%INPUT%\jpackage" rd /S /Q "%INPUT%\jpackage"  rem Eingabeordner fuer jpackage leeren
mkdir "%INPUT%\jpackage"

copy "target\bitchanger-%VERSION%-jar-with-dependencies.jar" "%INPUT%\%VERSION%\bitchanger-%VERSION%-jar-with-dependencies.jar" >nul
copy "target\bitchanger-%VERSION%.jar" "%INPUT%\%VERSION%\bitchanger-%VERSION%.jar" >nul
copy "target\bitchanger-%VERSION%-jar-with-dependencies.jar" "%INPUT%\jpackage\bitchanger-%VERSION%.jar" >nul


rem ---- Installer erzeugen ----------------------------------------------------------------------------------------------
echo.
echo Installer fuer Windows werden erzeugt.
echo.

call build_installer_win.bat VERSION=%VERSION% INPUT=%INPUT% OUT=%OUT%
if errorlevel 1 (
    echo Fehler: Windows-Installer-Erzeugung fehlgeschlagen.
    exit /b 1
)

echo.
echo Fertig.
