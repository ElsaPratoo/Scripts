#!/bin/bash

#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

INPUT="$1"

#comprovació de que hi ha un input
if [ -z "$INPUT" ]; then 
  echo -e "${RED} Error, és necessàri un fitxer . doc o .docx com a argument${RESET}"
fi 

#comprovació de si existeix fitxer
if [ ! -f "$INPUT" ]; then
  echo -e "${RED}Error: no s'ha trobat el fitxer '$INPUT'${RESET}"
  exit 1
fi 

#extensió del fitxer
FILENAME="$(basename "$INPUT")"
EXT="${FILENAME##*.}"
EXT_LOWER="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"
BASENAME="${FILENAME%.*}"
FILEDIR="$(dirname "$INPUT")"
OUTPUT="${FILEDIR}/${BASENAME}.pdf"
LOGFILE="${FILEDIR}/doc2pdf-error.log"

#comprovar que l'extensió és correcte
if [[ "$EXT" != "doc" && "$EXT" != "docx" ]]; then
  echo -e "${RED}Error: Només s'admeten fitxers .doc o .docx${RESET}"
  exit 0
fi 

#log d'errors
errors() {
  echo -e "${RED} Error: $1${RESET}"
  echo "[$(date +'%F %T')] $INPUT --> $1" >> "$LOGFILE"
  exit 1
}

#fitxer buit?
if [[ ! -s "$INPUT" ]]; then
  errors "Fitxer buit (0 bytes)."
fi 

#zip vàlid?
if ! unzip -tq "$INPUT" > /dev/null 2>&1; then 
  errors "No es un fitxer vàlid. Està malmès o és corrupte"
fi 

#contingut?
if ! unzip -l "$INPUT" | grep -q "word/document.xml"; then
  errors "El fitxer no contè cap document"
fi 

#no reconvertir si el pdf ja existeix i està actualitzat
if [[ -f "$OUTPUT" && "$INPUT" -ot "$OUTPUT" ]]; then
  echo -e "${GREEN}El PDF està al dia.${RESET}"
  exit -1 
fi 

#generar pdf
if command -v soffice >/dev/null 2>&1; then
  echo -e "${YELLOW}Convertitn a pdf mitjançant LibreOffice...${RESET}"
  soffice --headless --convert-to pdf "$INPUT" --outdir "$PDFDIR" > /dev/null 2>&1
  if [[ -f "$OUTPUT" ]]; then
    echo -e "${GREEN}Conversió completa${RESET}"
    exit 0
  else
    errors "No s'ha pogut generar el PDF. Soffice funciona correctament?"
  fi 
else
  errors "LiberOffice no està instalat"
fi
