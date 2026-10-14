#!/bin/sh
set -e

cd "$(dirname "$0")" || exit 1

# Dieses Skript erstellt mit Hilfe von Maven eine ausfuehrbare JAR-Datei aus dem Java-Projekt.
# Anschliessend wird mit dem jpackage-Tool aus der JAR-Datei ein nativer Installer fuer macOS erstellt.
# Alle benoetigten Komponenten (JRE, JavaFX, ...) werden dabei mit in den Installer eingebunden,
# sodass das Programm nach der Installation ohne zusaetzliche Installationen lauffaehig ist.

# Hinweis: Fuer Signierung und Notarisierung benoetigt jpackage ein entsprechendes Apple-Entwicklerzertifikat.

# ---- Konfiguration ---------------------------------------------------------------------------------------------------

NAME="Bitchanger"
DESCRIPTION="Rechner fuer beliebige Zahlensysteme"
VERSION="1.1.0"
VENDOR="Entwicklungsprojekt_EB2020 by Tim Muehle and Moritz Wolter"
# COPYRIGHT="Copyright 2020 (c) Tim Muehle & Moritz Wolter"

LICENSE_FILE="installer/source/Mac/jpackage/LICENSE.txt"

MAIN_JAR="bitchanger-${VERSION}.jar"
INPUT="installer/source/Mac"
OUT="installer/${VERSION}/macOS"

# ---- Praefluege -----------------------------------------------------------------------------------------------------

command -v mvn >/dev/null 2>&1 || { echo "Fehler: Maven (mvn) nicht gefunden." >&2; exit 1; }
command -v jpackage >/dev/null 2>&1 || { echo "Fehler: jpackage nicht gefunden. Bitte mit JDK 25+ verwenden." >&2; exit 1; }

if [ ! -f "./Logo/${NAME}.icns" ]; then
    echo "Fehler: Icon ./Logo/${NAME}.icns nicht gefunden." >&2
    exit 1
fi

if [ ! -f "./LICENSE.txt" ]; then
    echo "Fehler: LICENSE.txt nicht gefunden." >&2
    exit 1
fi

# ---- Maven build -----------------------------------------------------------------------------------------------------

echo ""
echo "Maven build durchfuehren"
echo ""
mvn clean install

# ---- JARs sichern ----------------------------------------------------------------------------------------------------

echo "JAR-Dateien kopieren"

mkdir -p "${OUT}"
mkdir -p "${INPUT}/jpackage"
mkdir -p "${INPUT}/${VERSION}"

cp "target/bitchanger-${VERSION}-jar-with-dependencies.jar" "${INPUT}/${VERSION}/bitchanger-${VERSION}-jar-with-dependencies.jar"
cp "target/bitchanger-${VERSION}.jar" "${INPUT}/${VERSION}/bitchanger-${VERSION}.jar"

rm -rf "${INPUT}/jpackage/"*     # Eingabeordner fuer jpackage leeren
cp "target/bitchanger-${VERSION}-jar-with-dependencies.jar" "${INPUT}/jpackage/${MAIN_JAR}"
cp "./LICENSE.txt" "./${LICENSE_FILE}"

# ---- Installer erzeugen ----------------------------------------------------------------------------------------------

echo ""
echo "Installer fuer macOS werden erzeugt."
echo ""

for TYPE in "pkg" "dmg"; do
    echo "${NAME}-${VERSION}-mac-install.${TYPE} wird erstellt"
    echo ""

    jpackage \
        --type "${TYPE}" \
        --name "${NAME}" \
        --description "${DESCRIPTION}" \
        --vendor "${VENDOR}" \
        --app-version "${VERSION}" \
        --input "${INPUT}/jpackage" \
        --dest "${OUT}" \
        --main-jar "${MAIN_JAR}" \
        --java-options --enable-native-access=javafx.graphics \
        --mac-package-name "${NAME}" \
        --license-file "${LICENSE_FILE}" \
        --icon "./Logo/${NAME}.icns"

    echo ""

    GENERATED="${OUT}/${NAME}-${VERSION}.${TYPE}"
    if [ ! -f "${GENERATED}" ]; then
        echo "Fehler: Erwartete Datei ${GENERATED} wurde nicht erzeugt." >&2
        exit 1
    fi

    mv "${GENERATED}" "${OUT}/${NAME}-${VERSION}-mac-install.${TYPE}"
    echo "${OUT}/${NAME}-${VERSION}-mac-install.${TYPE} erzeugt."
    echo ""
done
