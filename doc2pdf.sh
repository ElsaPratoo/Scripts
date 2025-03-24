#!/bin/bash

#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

INPUT="$1"

if [ -z "$INPUT" ]; then 
  echo -e "${RED} Error, és necessàri un fitxer . doc o .docx com a argument${RESET}"
fi 

if [ ! -f "$INPUT" ]; then
  echo -e "${RED}Error: no s'ha trobat el fitxer '$INPUT'${RESET}"
  exit 1
fi 

FILENAME="$(basename "$INPUT")"
EXT="${FILENAME##*.}"
EXT_LOWER="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"
BASENAME="${FILENAME%.*}"
PDFDIR="$(dirname "$INPUT")"
OUTPUT="${PDFDIR}/${BASENAME}.pdf"

if [[ "$EXT" != "doc" && "$EXT" != "docx" ]]; then
  echo -e "${RED}Error: Només s'admeten fitxers .doc o .docx${RESET}"
  echo 1
fi 

if command -v soffice >/dev/null 2>&1; then
  echo -e "${YELLOW}Convertitn a pdf mitjançant LibreOffice...${RESET}"
  soffice --headless --convert-to pdf "$INPUT" --outdir "$PDFDIR" > /dev/null 2>&1
  if [[ -f "$OUTPUT" ]]; then
    echo -e "${GREEN}Conversió completa${RESET}"
  else
    echo -e "${RED}Error: No s'ha pogut generar el PDF. Soffice funciona correctament?${RESET}"
    exit 1
  fi 
else
  echo -e "${RED}Error: No s'ha trobat LibreOffice (soffice)${RESET}"
  echo -e "${YELLOW} Altres opcions son unoconv o pandoc${RESET}"
  exit 1
fi
