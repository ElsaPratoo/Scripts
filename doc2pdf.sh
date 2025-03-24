#!/bin/bash

#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

INPUT="$1"
BASEMANE="$(basename "$INPUT" .doc)"
BASEMANE="$(basename "$BASEMANE" .docx)"
OUTDIR="$(dirname "$INPUT")"
OUTPUT="${OUTDIR}/${BASEMANE}.pdf"

if [ -z "$INPUT" ]; then 
  echo -e "${RED} Error, és necessàri un fitxer . doc o .docx com a argument${RESET}"
fi 

if [ ! -f "$INPUT" ]; then
  echo -e "${RED}Error: no s'ha trobat el fitxer '$INPUT'${RESET}"
  exit 1
fi 

EXT="${INPUT##*.}"

if [[ "$EXT" != ".doc" && "$EXT" != ".docx" ]]; then
  echo -e "${RED}Error: Només s'admeten fitxers .doc o .docx${RESET}"
  echo 1
fi 

if command -v soffice >/dev/null 2>&1; then
  echo "${YELLOW}Convertitn a pdf mitjançant LibreOffice...${RESET}"
  soffice --headless --convert-to pdf "$INPUT" --outdir "$OUTDIR"
  if [[ -f "$OUTPUT" ]]; then
    echo -e "${GREEN}Conversió completa. Fitxer generat:${RESET} '${OUTPUT}"
  else
    echo -e "${RED}Error: No s'ha pogut generar el PDF. Soffice funciona correctament?${RESET}"
    exit 1
  fi 
else
  echo -e "${RED}Error: No s'ha trobat LibreOffice (soffice)${RESET}"
  echo -e "${YELLOW} Altres opcions son unoconv o pandoc${RESET}"
  exit 1
fi 
